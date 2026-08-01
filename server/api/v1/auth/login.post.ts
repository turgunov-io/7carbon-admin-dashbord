import { loginSchema } from '@shared/validators'
import { login } from '../../../services/auth.service'
import { readValidatedJson, ok } from '../../../utils/response'
import { recordAudit } from '../../../services/audit.service'

/** POST /api/v1/auth/login — issue access + refresh cookies. */
export default defineEventHandler(async (event) => {
  const { email, password } = await readValidatedJson(event, loginSchema)
  const user = await login(event, email, password)
  await recordAudit(event, user.id, 'auth.login', 'User', user.id)
  return ok(user)
})
