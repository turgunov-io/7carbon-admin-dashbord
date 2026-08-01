import { deleteProduct } from '../../../services/product.service'
import { ok } from '../../../utils/response'
import { requireRole } from '../../../utils/context'
import { recordAudit } from '../../../services/audit.service'

/** DELETE /api/v1/products/:id — admin soft-delete (archive). */
export default defineEventHandler(async (event) => {
  const user = await requireRole(event, 'ADMIN')
  const id = getRouterParam(event, 'id')!
  await deleteProduct(id)
  await recordAudit(event, user.sub, 'product.delete', 'Product', id)
  return ok({ id, deleted: true })
})
