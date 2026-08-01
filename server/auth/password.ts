/**
 * Password hashing with Argon2id (doc 13_Security). Uses @node-rs/argon2 —
 * prebuilt native bindings, so no compiler toolchain is required on Windows.
 */
import { hash, verify } from '@node-rs/argon2'

const ARGON2_OPTIONS = {
  // OWASP-aligned parameters for Argon2id.
  memoryCost: 19_456,
  timeCost: 2,
  parallelism: 1,
} as const

export function hashPassword(plain: string): Promise<string> {
  return hash(plain, ARGON2_OPTIONS)
}

export function verifyPassword(hashValue: string, plain: string): Promise<boolean> {
  return verify(hashValue, plain, ARGON2_OPTIONS).catch(() => false)
}
