import { consultationStats } from '../../../services/consultation.service'
import { ok } from '../../../utils/response'
import { requireAuth } from '../../../utils/context'

/** GET /api/v1/consultations/stats — CRM counters for dashboard widgets. */
export default defineEventHandler(async (event) => {
  await requireAuth(event)
  return ok(await consultationStats())
})
