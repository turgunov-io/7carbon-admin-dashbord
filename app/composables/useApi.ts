/**
 * Thin API client for the dashboard. Wraps `$fetch` against the same-origin
 * `/api/v1` backend, unwraps the `{ success, data }` envelope and forwards
 * cookies during SSR so authenticated calls work on the server too.
 */
import type { ApiResponse, PaginationMeta } from '@shared/types'

interface RequestOptions {
  method?: 'GET' | 'POST' | 'PATCH' | 'DELETE'
  body?: unknown
  query?: Record<string, unknown>
}

export function useApi() {
  const config = useRuntimeConfig()
  const base = config.public.apiBase

  async function request<T>(path: string, options: RequestOptions = {}): Promise<{ data: T; meta?: PaginationMeta }> {
    const headers = import.meta.server ? useRequestHeaders(['cookie']) : undefined
    const res = await $fetch<ApiResponse<T>>(`${base}${path}`, {
      method: options.method ?? 'GET',
      body: options.body as never,
      query: options.query,
      headers,
      credentials: 'include',
    }).catch((err) => {
      const payload = err?.data as ApiResponse<T> | undefined
      throw createError({
        statusCode: err?.statusCode ?? 500,
        statusMessage: payload && !payload.success ? payload.message : 'Ошибка запроса',
        data: payload,
      })
    })
    if (!res.success) {
      throw createError({ statusCode: 400, statusMessage: res.message, data: res })
    }
    return { data: res.data, meta: (res as { meta?: PaginationMeta }).meta }
  }

  return {
    get: <T>(path: string, query?: Record<string, unknown>) => request<T>(path, { query }),
    post: <T>(path: string, body?: unknown) => request<T>(path, { method: 'POST', body }),
    patch: <T>(path: string, body?: unknown) => request<T>(path, { method: 'PATCH', body }),
    delete: <T>(path: string) => request<T>(path, { method: 'DELETE' }),
  }
}
