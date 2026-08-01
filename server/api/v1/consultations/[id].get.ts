import { getConsultation } from '../../../services/consultation.service'
import { fail, ok } from '../../../utils/response'
import { requireAuth } from '../../../utils/context'

/** GET /api/v1/consultations/:id — single request detail (admin). */
export default defineEventHandler(async (event) => {
  await requireAuth(event)
  const id = getRouterParam(event, 'id')!
  const item = await getConsultation(id)
  if (!item) fail(404, 'Заявка не найдена')
  return ok(item)
})
