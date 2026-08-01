import { getPublicSettings } from '../../services/content.service'
import { ok } from '../../utils/response'

/** GET /api/v1/settings — public company contact settings. */
export default defineEventHandler(async () => ok(await getPublicSettings()))
