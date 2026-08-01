// 7Carbon Dashboard — Nuxt 4 SSR (admin panel + backend Nuxt Server API).
// SSR is mandatory here (doc 22_AI_Rules): the dashboard must stay server-rendered.
import { fileURLToPath } from 'node:url'

export default defineNuxtConfig({
  compatibilityDate: '2025-01-01',
  ssr: true,
  future: { compatibilityVersion: 4 },

  modules: [
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt',
    '@vueuse/nuxt',
    '@nuxt/eslint',
  ],

  css: ['~/assets/css/main.css'],

  // Resolve components by filename (PascalCase) rather than directory-prefixed
  // names, so <DashboardSidebar>, <StatCard>, <BaseIcon> etc. resolve wherever
  // they live in the component tree.
  components: [{ path: '~/components', pathPrefix: false }],

  alias: {
    '@shared': fileURLToPath(new URL('../shared', import.meta.url)),
  },

  runtimeConfig: {
    // Server-only secrets.
    databaseUrl: process.env.DATABASE_URL,
    jwtAccessSecret: process.env.JWT_ACCESS_SECRET,
    jwtRefreshSecret: process.env.JWT_REFRESH_SECRET,
    corsOrigins: process.env.CORS_ORIGINS ?? 'http://localhost:3000',
    storageDir: process.env.STORAGE_DIR ?? './public/uploads',
    public: {
      appName: '7Carbon Dashboard',
      apiBase: '/api/v1',
    },
  },

  nitro: {
    compressPublicAssets: true,
    // Security headers applied globally (doc 13_Security).
    routeRules: {
      '/**': {
        headers: {
          'X-Content-Type-Options': 'nosniff',
          'X-Frame-Options': 'DENY',
          'Referrer-Policy': 'strict-origin-when-cross-origin',
          'Permissions-Policy': 'geolocation=(), microphone=(), camera=()',
        },
      },
    },
  },

  typescript: { strict: true, typeCheck: false },

  app: {
    head: {
      htmlAttrs: { lang: 'ru', class: 'dark' },
      title: '7Carbon — Admin',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'robots', content: 'noindex, nofollow' },
      ],
    },
  },

  devtools: { enabled: true },
})
