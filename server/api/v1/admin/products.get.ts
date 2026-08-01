import { paginationSchema } from '@shared/validators'
import { listProducts } from '../../../services/product.service'
import { ok, parseOrFail } from '../../../utils/response'
import { requireAuth } from '../../../utils/context'

/** GET /api/v1/admin/products — admin listing including DRAFT/ARCHIVED. */
export default defineEventHandler(async (event) => {
  await requireAuth(event)
  const q = getQuery(event)
  const base = parseOrFail(paginationSchema, q)
  const result = await listProducts({
    ...base,
    includeAll: true,
    categorySlug: typeof q.category === 'string' ? q.category : undefined,
  })
  return ok(result.items, result.meta)
})
