import { defineStore } from 'pinia'
import type { AuthUser } from '@shared/types'

/** Authenticated admin session state. */
export const useAuthStore = defineStore('auth', () => {
  const user = ref<AuthUser | null>(null)
  const isAuthenticated = computed(() => !!user.value)

  async function fetchMe(): Promise<AuthUser | null> {
    const api = useApi()
    try {
      const { data } = await api.get<AuthUser>('/auth/me')
      user.value = data
    } catch {
      user.value = null
    }
    return user.value
  }

  async function login(email: string, password: string): Promise<void> {
    const api = useApi()
    const { data } = await api.post<AuthUser>('/auth/login', { email, password })
    user.value = data
  }

  async function logout(): Promise<void> {
    const api = useApi()
    await api.post('/auth/logout').catch(() => {})
    user.value = null
    await navigateTo('/login')
  }

  return { user, isAuthenticated, fetchMe, login, logout }
})
