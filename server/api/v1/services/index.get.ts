import { listServices } from '../../../services/content.service'
import { ok } from '../../../utils/response'

/** GET /api/v1/services — public list of atelier services. */
export default defineEventHandler(async () => ok(await listServices()))
