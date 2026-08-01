import { z } from 'zod'
import { consultationStatusSchema } from '@shared/validators'
import { updateConsultation } from '../../../services/consultation.service'
import { readValidatedJson, ok } from '../../../utils/response'
import { requireAuth } from '../../../utils/context'
import { recordAudit } from '../../../services/audit.service'

const patchSchema = z.object({
  status: consultationStatusSchema.optional(),
  managerNotes: z.string().max(4000).optional(),
})

/** PATCH /api/v1/consultations/:id — update CRM status / notes, assign manager. */
export default defineEventHandler(async (event) => {
  const user = await requireAuth(event)
  const id = getRouterParam(event, 'id')!
  const data = await readValidatedJson(event, patchSchema)
  const updated = await updateConsultation(id, { ...data, managerId: user.sub })
  await recordAudit(event, user.sub, 'consultation.update', 'Consultation', id)
  return ok(updated)
})
