import { productUpdateSchema } from '@shared/validators'
import { updateProduct } from '../../../services/product.service'
import { readValidatedJson, ok } from '../../../utils/response'
import { requireRole } from '../../../utils/context'
import { recordAudit } from '../../../services/audit.service'

/** PATCH /api/v1/products/:id — admin update. */
export default defineEventHandler(async (event) => {
  const user = await requireRole(event, 'ADMIN')
  const id = getRouterParam(event, 'id')!
  const data = await readValidatedJson(event, productUpdateSchema)
  const product = await updateProduct(id, data)
  await recordAudit(event, user.sub, 'product.update', 'Product', id)
  return ok(product)
})
