import { listPartners } from '../../../services/content.service'
import { ok } from '../../../utils/response'

/** GET /api/v1/partners — partner brand logos. */
export default defineEventHandler(async () => ok(await listPartners()))
