/**
 * CORS for the public API. The Landing SPA runs on a different origin and must
 * be allowlisted explicitly (doc 09/13). Credentials are enabled for cookies.
 */
export default defineEventHandler((event) => {
  const url = getRequestURL(event)
  if (!url.pathname.startsWith('/api/')) return

  const config = useRuntimeConfig()
  const allowed = String(config.corsOrigins).split(',').map((o) => o.trim())
  const origin = getRequestHeader(event, 'origin')

  if (origin && allowed.includes(origin)) {
    setResponseHeader(event, 'Access-Control-Allow-Origin', origin)
    setResponseHeader(event, 'Access-Control-Allow-Credentials', 'true')
    setResponseHeader(event, 'Vary', 'Origin')
  }
  setResponseHeader(event, 'Access-Control-Allow-Methods', 'GET,POST,PATCH,DELETE,OPTIONS')
  setResponseHeader(event, 'Access-Control-Allow-Headers', 'Content-Type, Authorization')

  if (event.method === 'OPTIONS') {
    setResponseStatus(event, 204)
    return ''
  }
})
