/**
 * Request auth context. Reads the access-token cookie, verifies it and returns
 * the caller. RBAC helpers enforce the default-deny policy (doc 13/19).
 */
import type { H3Event } from 'h3'
import type { UserRole } from '@prisma/client'
import { verifyAccessToken, type AccessClaims } from '../auth/jwt'
import { fail } from './response'

const ACCESS_COOKIE = '7c_at'

export async function getOptionalUser(event: H3Event): Promise<AccessClaims | null> {
  const token = getCookie(event, ACCESS_COOKIE)
  if (!token) return null
  try {
    return await verifyAccessToken(token)
  } catch {
    return null
  }
}

/** Require an authenticated user or throw 401. */
export async function requireAuth(event: H3Event): Promise<AccessClaims> {
  const user = await getOptionalUser(event)
  if (!user) fail(401, 'Требуется авторизация')
  return user
}

const ROLE_RANK: Record<UserRole, number> = {
  MANAGER: 1,
  ADMIN: 2,
  SUPER_ADMIN: 3,
}

/** Require a minimum role (default-deny). */
export async function requireRole(event: H3Event, minRole: UserRole): Promise<AccessClaims> {
  const user = await requireAuth(event)
  if (ROLE_RANK[user.role] < ROLE_RANK[minRole]) {
    fail(403, 'Недостаточно прав')
  }
  return user
}
