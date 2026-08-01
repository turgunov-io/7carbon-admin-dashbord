import { logout } from '../../../services/auth.service'
import { ok } from '../../../utils/response'
import { getOptionalUser } from '../../../utils/context'
import { recordAudit } from '../../../services/audit.service'

/** POST /api/v1/auth/logout — revoke session and clear cookies. */
export default defineEventHandler(async (event) => {
  const user = await getOptionalUser(event)
  await logout(event)
  if (user) await recordAudit(event, user.sub, 'auth.logout', 'User', user.sub)
  return ok({ loggedOut: true })
})
