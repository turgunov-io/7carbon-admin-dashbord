/**
 * Global auth guard. Every dashboard route is protected except /login
 * (doc 13: protected routes + role middleware). Resolves the session on the
 * server so SSR renders the correct state without a flash of the login screen.
 */
export default defineNuxtRouteMiddleware(async (to) => {
  const auth = useAuthStore()

  if (!auth.user) {
    await auth.fetchMe()
  }

  if (to.path === '/login') {
    if (auth.isAuthenticated) return navigateTo('/')
    return
  }

  if (!auth.isAuthenticated) {
    return navigateTo(`/login?redirect=${encodeURIComponent(to.fullPath)}`)
  }
})
