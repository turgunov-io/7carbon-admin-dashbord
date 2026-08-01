import { PrismaClient } from '@prisma/client'
import { hash } from '@node-rs/argon2'

const email = process.argv[2]
const password = process.argv[3]
if (!email || !password) { console.error('usage: set-admin-password <email> <password>'); process.exit(1) }

// Same Argon2id parameters as server/auth/password.ts (params are also encoded in the hash).
const ARGON2 = { memoryCost: 19456, timeCost: 2, parallelism: 1 }

const prisma = new PrismaClient()
const passwordHash = await hash(password, ARGON2)
const user = await prisma.user.update({ where: { email }, data: { passwordHash } })
console.log(`✓ Password updated for ${user.email} (${user.role})`)
await prisma.$disconnect()
