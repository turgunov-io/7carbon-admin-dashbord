import { listGallery } from '../../../services/content.service'
import { ok } from '../../../utils/response'

/** GET /api/v1/gallery — published gallery imagery. */
export default defineEventHandler(async () => ok(await listGallery()))
