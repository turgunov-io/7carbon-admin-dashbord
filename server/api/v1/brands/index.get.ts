import { listBrands } from '../../../services/content.service'
import { ok } from '../../../utils/response'

/** GET /api/v1/brands — vehicle makes with their models (compatibility filter). */
export default defineEventHandler(async () => ok(await listBrands()))
