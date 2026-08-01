import { consultationSchema } from '@shared/validators'
import { createConsultation } from '../../../services/consultation.service'
import { readValidatedJson, ok } from '../../../utils/response'
import { logger } from '../../../utils/logger'

/**
 * POST /api/v1/consultations — public consultation submission (the core
 * conversion). Server-validated and persisted; the dashboard picks it up as NEW.
 */
export default defineEventHandler(async (event) => {
  const input = await readValidatedJson(event, consultationSchema)
  const consultation = await createConsultation(input)
  logger.info({ id: consultation.id }, 'New consultation request')
  setResponseStatus(event, 201)
  return ok({ id: consultation.id, status: consultation.status })
})
