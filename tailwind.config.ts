import type { Config } from 'tailwindcss'
import {
  colors,
  dashboardColors,
  radius,
  shadows,
  typography,
} from '../shared/design-tokens'

/** Dashboard Tailwind — enterprise dark surfaces (doc 21_Dashboard_UI). */
export default <Partial<Config>>{
  darkMode: 'class',
  content: [
    './app/**/*.{vue,ts}',
    './components/**/*.{vue,ts}',
    './layouts/**/*.vue',
    './pages/**/*.vue',
  ],
  theme: {
    extend: {
      colors: {
        ...colors,
        bg: dashboardColors.background,
        sidebar: dashboardColors.sidebar,
        surface: dashboardColors.surface,
        line: dashboardColors.border,
      },
      borderRadius: radius,
      boxShadow: shadows,
      fontFamily: {
        sans: typography.fontFamily.sans,
        display: typography.fontFamily.display,
        mono: typography.fontFamily.mono,
      },
    },
  },
}
