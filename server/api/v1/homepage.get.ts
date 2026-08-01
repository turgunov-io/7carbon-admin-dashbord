import { getHomepage } from '../../services/content.service'
import { ok } from '../../utils/response'

/** GET /api/v1/homepage — hero, about copy and metrics for the landing. */
export default defineEventHandler(async () => ok(await getHomepage()))
