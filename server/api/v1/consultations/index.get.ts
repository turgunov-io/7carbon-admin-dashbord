import { listConsultations } from '../../../services/consultation.service'
import { ok } from '../../../utils/response'
import { requireAuth } from '../../../utils/context'
import type { ConsultationStatus } from '@prisma/client'

/** GET /api/v1/consultations — admin CRM list with status filter + search. */
export default defineEventHandler(async (event) => {
  await requireAuth(event)
  const q = getQuery(event)
  const result = await listConsultations({
    page: Number(q.page ?? 1),
    pageSize: Number(q.pageSize ?? 20),
    status: typeof q.status === 'string' ? (q.status as ConsultationStatus) : undefined,
    search: typeof q.search === 'string' ? q.search : undefined,
  })
  return ok(result.items, result.meta)
})
