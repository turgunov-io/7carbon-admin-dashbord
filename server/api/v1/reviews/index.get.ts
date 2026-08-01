import { listReviews } from '../../../services/content.service'
import { ok } from '../../../utils/response'

/** GET /api/v1/reviews — published customer reviews. */
export default defineEventHandler(async () => ok(await listReviews()))
