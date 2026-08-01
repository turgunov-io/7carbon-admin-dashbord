import { refresh } from '../../../services/auth.service'
import { ok } from '../../../utils/response'

/** POST /api/v1/auth/refresh — rotate refresh token, re-issue access cookie. */
export default defineEventHandler(async (event) => ok(await refresh(event)))
