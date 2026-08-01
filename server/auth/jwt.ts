/**
 * JWT issuance/verification with `jose` (doc 13). Access token 15m, refresh 30d.
 * Tokens are delivered as HTTP-only, Secure, SameSite=Lax cookies by the caller.
 */
import { SignJWT, jwtVerify } from 'jose'
import type { UserRole } from '@prisma/client'

export interface AccessClaims {
  sub: string
  email: string
  role: UserRole
  type: 'access'
}

export interface RefreshClaims {
  sub: string
  sessionId: string
  type: 'refresh'
}

const ACCESS_TTL = '15m'
const REFRESH_TTL = '30d'

function secret(kind: 'access' | 'refresh'): Uint8Array {
  const config = useRuntimeConfig()
  const value = kind === 'access' ? config.jwtAccessSecret : config.jwtRefreshSecret
  if (!value) throw new Error(`Missing JWT ${kind} secret`)
  return new TextEncoder().encode(value)
}

export async function signAccessToken(claims: Omit<AccessClaims, 'type'>): Promise<string> {
  return new SignJWT({ ...claims, type: 'access' })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime(ACCESS_TTL)
    .sign(secret('access'))
}

export async function signRefreshToken(claims: Omit<RefreshClaims, 'type'>): Promise<string> {
  return new SignJWT({ ...claims, type: 'refresh' })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime(REFRESH_TTL)
    .sign(secret('refresh'))
}

export async function verifyAccessToken(token: string): Promise<AccessClaims> {
  const { payload } = await jwtVerify(token, secret('access'))
  if (payload.type !== 'access') throw new Error('Invalid token type')
  return payload as unknown as AccessClaims
}

export async function verifyRefreshToken(token: string): Promise<RefreshClaims> {
  const { payload } = await jwtVerify(token, secret('refresh'))
  if (payload.type !== 'refresh') throw new Error('Invalid token type')
  return payload as unknown as RefreshClaims
}
