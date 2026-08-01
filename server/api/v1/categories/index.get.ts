import { listCategories } from '../../../services/content.service'
import { ok } from '../../../utils/response'

/** GET /api/v1/categories — active product categories with product counts. */
export default defineEventHandler(async () => ok(await listCategories()))
