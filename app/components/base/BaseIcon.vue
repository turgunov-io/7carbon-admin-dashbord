<script setup lang="ts">
/**
 * Minimal stroke-icon set (consistent 1.6 stroke width, doc 04). Kept inline so
 * the dashboard has zero external icon dependency at runtime.
 */
const props = defineProps<{ name: string }>()

const paths: Record<string, string> = {
  grid: 'M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z',
  box: 'M21 8l-9-5-9 5v8l9 5 9-5zM3 8l9 5 9-5M12 13v8',
  folder: 'M3 7a2 2 0 012-2h4l2 2h8a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z',
  wrench: 'M14 7a4 4 0 00-5 5l-6 6 2 2 6-6a4 4 0 005-5l-2 2-2-2 2-2z',
  car: 'M5 13l1-4a2 2 0 012-2h8a2 2 0 012 2l1 4M4 13h16v4H4zM7 17v2M17 17v2',
  layers: 'M12 3l9 5-9 5-9-5zM3 13l9 5 9-5',
  home: 'M3 11l9-7 9 7M5 10v9h5v-6h4v6h5v-9',
  image: 'M4 5h16v14H4zM8 11a2 2 0 100-4 2 2 0 000 4zM4 17l5-5 4 4 3-3 4 4',
  upload: 'M12 16V4M8 8l4-4 4 4M4 20h16',
  star: 'M12 3l2.9 5.9 6.5.9-4.7 4.6 1.1 6.5L12 18l-5.8 3 1.1-6.5L2.6 9.8l6.5-.9z',
  help: 'M12 22a10 10 0 100-20 10 10 0 000 20zM9.5 9a2.5 2.5 0 013.9-2c1.6 1 .6 3-1.4 3.5V13M12 17h.01',
  inbox: 'M4 13l2-8h12l2 8M4 13v6h16v-6M4 13h5l1 2h4l1-2h5',
  search: 'M11 19a8 8 0 100-16 8 8 0 000 16zM21 21l-4.3-4.3',
  globe: 'M12 22a10 10 0 100-20 10 10 0 000 20zM2 12h20M12 2a15 15 0 000 20a15 15 0 000-20',
  users: 'M16 20v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2M9 10a4 4 0 100-8 4 4 0 000 8zM22 20v-2a4 4 0 00-3-3.9',
  settings: 'M12 15a3 3 0 100-6 3 3 0 000 6zM19 12a7 7 0 00-.1-1l2-1.6-2-3.4-2.4 1a7 7 0 00-1.7-1L14.5 3h-4l-.4 2.6a7 7 0 00-1.7 1l-2.4-1-2 3.4 2 1.6a7 7 0 000 2l-2 1.6 2 3.4 2.4-1a7 7 0 001.7 1l.4 2.4h4l.4-2.6a7 7 0 001.7-1l2.4 1 2-3.4-2-1.6a7 7 0 00.1-1z',
  bell: 'M18 8a6 6 0 10-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 01-3.4 0',
  menu: 'M4 6h16M4 12h16M4 18h16',
  logout: 'M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9',
  plus: 'M12 5v14M5 12h14',
  chevron: 'M9 18l6-6-6-6',
  check: 'M20 6L9 17l-5-5',
  x: 'M18 6L6 18M6 6l12 12',
  phone: 'M22 16.9v3a2 2 0 01-2.2 2 19.8 19.8 0 01-8.6-3 19.5 19.5 0 01-6-6 19.8 19.8 0 01-3-8.6A2 2 0 014.1 2h3a2 2 0 012 1.7c.1.9.3 1.8.7 2.7a2 2 0 01-.5 2.1L8.1 9.9a16 16 0 006 6l1.4-1.2a2 2 0 012.1-.5c.9.4 1.8.6 2.7.7a2 2 0 011.7 2z',
}

const d = computed(() => paths[props.name] ?? paths.help)
</script>

<template>
  <svg
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="1.6"
    stroke-linecap="round"
    stroke-linejoin="round"
    aria-hidden="true"
  >
    <path :d="d" />
  </svg>
</template>
