import { listFaq } from '../../../services/content.service'
import { ok } from '../../../utils/response'

/** GET /api/v1/faq — published FAQ entries. */
export default defineEventHandler(async () => ok(await listFaq()))
