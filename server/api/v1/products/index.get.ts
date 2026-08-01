import { paginationSchema } from '@shared/validators'
import { listProducts } from '../../../services/product.service'
import { ok, parseOrFail } from '../../../utils/response'

/** GET /api/v1/products — public catalog with pagination, search and filters. */
export default defineEventHandler(async (event) => {
  const q = getQuery(event)
  const base = parseOrFail(paginationSchema, q)
  const result = await listProducts({
    ...base,
    categorySlug: typeof q.category === 'string' ? q.category : undefined,
    brandSlug: typeof q.brand === 'string' ? q.brand : undefined,
    supplierBrand: typeof q.supplier === 'string' ? q.supplier : undefined,
  })
  return ok(result.items, result.meta)
})
