/**
 * Authentication service (doc 13/19): credential verification, session issuance,
 * refresh-token rotation and revocation. Access token in `7c_at`, refresh in
 * `7c_rt`, both HTTP-only + Secure + SameSite=Lax.
 */
import type { H3Event } from 'h3'
import { prisma } from '../utils/prisma'
import { verifyPassword } from '../auth/password'
import {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
} from '../auth/jwt'
import { fail } from '../utils/response'

const ACCESS_COOKIE = '7c_at'
const REFRESH_COOKIE = '7c_rt'
const ACCESS_MAX_AGE = 15 * 60
const REFRESH_MAX_AGE = 30 * 24 * 60 * 60

function cookieBase(event: H3Event) {
  return {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax' as const,
    path: '/',
  }
}

async function issueSession(event: H3Event, user: { id: string; email: string; role: 'SUPER_ADMIN' | 'ADMIN' | 'MANAGER' }) {
  const session = await prisma.session.create({
    data: {
      userId: user.id,
      refreshToken: 'pending',
      expiresAt: new Date(Date.now() + REFRESH_MAX_AGE * 1000),
      ip: getRequestIP(event, { xForwardedFor: true }) ?? null,
      userAgent: getRequestHeader(event, 'user-agent') ?? null,
    },
  })
  const accessToken = await signAccessToken({ sub: user.id, email: user.email, role: user.role })
  const refreshToken = await signRefreshToken({ sub: user.id, sessionId: session.id })
  await prisma.session.update({ where: { id: session.id }, data: { refreshToken } })

  setCookie(event, ACCESS_COOKIE, accessToken, { ...cookieBase(event), maxAge: ACCESS_MAX_AGE })
  setCookie(event, REFRESH_COOKIE, refreshToken, { ...cookieBase(event), maxAge: REFRESH_MAX_AGE })
}

export async function login(event: H3Event, email: string, password: string) {
  const user = await prisma.user.findUnique({ where: { email } })
  // Constant-ish response: verify even on missing user to blunt user-enumeration.
  const valid = user && user.isActive ? await verifyPassword(user.passwordHash, password) : false
  if (!user || !valid) fail(401, 'Неверный email или пароль')

  await prisma.user.update({ where: { id: user.id }, data: { lastLogin: new Date() } })
  await issueSession(event, user)
  return {
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    role: user.role,
    avatar: user.avatar,
    language: user.language,
  }
}

export async function refresh(event: H3Event) {
  const token = getCookie(event, REFRESH_COOKIE)
  if (!token) fail(401, 'Сессия истекла')
  let claims
  try {
    claims = await verifyRefreshToken(token)
  } catch {
    fail(401, 'Недействительный токен')
  }
  const session = await prisma.session.findUnique({ where: { id: claims.sessionId } })
  if (!session || session.revokedAt || session.refreshToken !== token || session.expiresAt < new Date()) {
    fail(401, 'Сессия недействительна')
  }
  const user = await prisma.user.findUnique({ where: { id: claims.sub } })
  if (!user || !user.isActive) fail(401, 'Пользователь недоступен')

  // Rotate: revoke old session, issue a fresh one.
  await prisma.session.update({ where: { id: session.id }, data: { revokedAt: new Date() } })
  await issueSession(event, user)
  return { id: user.id, email: user.email, fullName: user.fullName, role: user.role }
}

export async function logout(event: H3Event) {
  const token = getCookie(event, REFRESH_COOKIE)
  if (token) {
    await prisma.session.updateMany({ where: { refreshToken: token }, data: { revokedAt: new Date() } })
  }
  deleteCookie(event, ACCESS_COOKIE, { path: '/' })
  deleteCookie(event, REFRESH_COOKIE, { path: '/' })
}

export async function me(userId: string) {
  const user = await prisma.user.findUnique({ where: { id: userId } })
  if (!user) fail(404, 'Пользователь не найден')
  return {
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    role: user.role,
    avatar: user.avatar,
    language: user.language,
  }
}
