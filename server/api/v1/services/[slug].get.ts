import { getServiceBySlug } from '../../../services/content.service'
import { fail, ok } from '../../../utils/response'

/** GET /api/v1/services/:slug — single service detail. */
export default defineEventHandler(async (event) => {
  const slug = getRouterParam(event, 'slug')!
  const service = await getServiceBySlug(slug)
  if (!service) fail(404, 'Услуга не найдена')
  return ok(service)
})
