import { productCreateSchema } from '@shared/validators'
import { createProduct } from '../../../services/product.service'
import { readValidatedJson, ok } from '../../../utils/response'
import { requireRole } from '../../../utils/context'
import { recordAudit } from '../../../services/audit.service'

/** POST /api/v1/products — admin create. */
export default defineEventHandler(async (event) => {
  const user = await requireRole(event, 'ADMIN')
  const data = await readValidatedJson(event, productCreateSchema)
  const product = await createProduct(data)
  await recordAudit(event, user.sub, 'product.create', 'Product', product.id)
  setResponseStatus(event, 201)
  return ok(product)
})
