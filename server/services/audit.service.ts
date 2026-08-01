/**
 * Audit trail for admin actions (doc 13). Records who did what, from where.
 * Failures here must never break the request, so writes are best-effort.
 */
import type { H3Event } from 'h3'
import { prisma } from '../utils/prisma'
import { logger } from '../utils/logger'

export async function recordAudit(
  event: H3Event,
  userId: string | null,
  action: string,
  entity: string,
  entityId?: string,
): Promise<void> {
  try {
    await prisma.auditLog.create({
      data: {
        userId,
        action,
        entity,
        entityId: entityId ?? null,
        ip: getRequestIP(event, { xForwardedFor: true }) ?? null,
        userAgent: getRequestHeader(event, 'user-agent') ?? null,
      },
    })
  } catch (err) {
    logger.warn({ err, action }, 'Failed to write audit log')
  }
}
