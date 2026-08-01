import { me } from '../../../services/auth.service'
import { ok } from '../../../utils/response'
import { requireAuth } from '../../../utils/context'

/** GET /api/v1/auth/me — current authenticated user. */
export default defineEventHandler(async (event) => {
  const claims = await requireAuth(event)
  return ok(await me(claims.sub))
})
