import { prisma } from '../../utils/prisma'
import { ok } from '../../utils/response'

/** GET /api/v1/health — liveness + DB check for monitoring (doc 19). */
export default defineEventHandler(async () => {
  let database = 'down'
  try {
    await prisma.$queryRaw`SELECT 1`
    database = 'up'
  } catch {
    database = 'down'
  }
  return ok({ status: 'ok', database, timestamp: new Date().toISOString() })
})
