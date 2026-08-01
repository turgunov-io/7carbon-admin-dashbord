/**
 * Global error normalizer (doc 19). Renders every thrown error as the standard
 * `{ success:false, message, errors }` envelope and never leaks stack traces.
 */
import { logger } from '../utils/logger'

export default defineNitroPlugin((nitro) => {
  nitro.hooks.hook('error', (error) => {
    logger.error({ err: error }, 'Unhandled API error')
  })

  nitro.hooks.hook('beforeResponse', (event, response) => {
    const err = response.body as { statusCode?: number; data?: unknown } | undefined
    if (!getRequestURL(event).pathname.startsWith('/api/')) return
    if (err && typeof err === 'object' && 'statusCode' in err && err.statusCode && err.statusCode >= 400) {
      const data = (err.data ?? {}) as { message?: string; errors?: unknown }
      response.body = {
        success: false,
        message: data.message ?? 'Внутренняя ошибка сервера',
        errors: data.errors ?? [],
      }
    }
  })
})
