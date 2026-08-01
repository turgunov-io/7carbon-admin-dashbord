import { getProductBySlug } from '../../../../services/product.service'
import { fail, ok } from '../../../../utils/response'

/** GET /api/v1/products/slug/:slug — single product detail for the storefront. */
export default defineEventHandler(async (event) => {
  const slug = getRouterParam(event, 'slug')!
  const product = await getProductBySlug(slug)
  if (!product) fail(404, 'Товар не найден')
  return ok(product)
})
