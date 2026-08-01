<script setup lang="ts">
/** Collapsible admin sidebar with the full module set (doc 21_Dashboard_UI). */
const props = defineProps<{ collapsed: boolean }>()

interface NavItem {
  label: string
  to: string
  icon: string
}

// Grouped navigation matching the specified module list.
const groups: { title: string; items: NavItem[] }[] = [
  {
    title: 'Обзор',
    items: [{ label: 'Дашборд', to: '/', icon: 'grid' }],
  },
  {
    title: 'Каталог',
    items: [
      { label: 'Товары', to: '/products', icon: 'box' },
      { label: 'Категории', to: '/categories', icon: 'folder' },
      { label: 'Услуги', to: '/services', icon: 'wrench' },
      { label: 'Марки', to: '/brands', icon: 'car' },
      { label: 'Модели', to: '/models', icon: 'layers' },
    ],
  },
  {
    title: 'Контент',
    items: [
      { label: 'Главная', to: '/homepage', icon: 'home' },
      { label: 'Галерея', to: '/gallery', icon: 'image' },
      { label: 'Медиа', to: '/media', icon: 'upload' },
      { label: 'Отзывы', to: '/reviews', icon: 'star' },
      { label: 'FAQ', to: '/faq', icon: 'help' },
    ],
  },
  {
    title: 'CRM',
    items: [{ label: 'Заявки', to: '/consultations', icon: 'inbox' }],
  },
  {
    title: 'Система',
    items: [
      { label: 'SEO', to: '/seo', icon: 'search' },
      { label: 'Переводы', to: '/translations', icon: 'globe' },
      { label: 'Пользователи', to: '/users', icon: 'users' },
      { label: 'Настройки', to: '/settings', icon: 'settings' },
    ],
  },
]
</script>

<template>
  <aside
    class="flex h-screen flex-col border-r border-line bg-sidebar transition-all duration-250"
    :class="props.collapsed ? 'w-[76px]' : 'w-[280px]'"
  >
    <div class="flex h-[72px] items-center px-5">
      <img v-if="!props.collapsed" src="/logo.svg" alt="7 Carbon" class="h-8 w-auto" width="146" height="32">
      <img v-else src="/logo.svg" alt="7 Carbon" class="h-7 w-auto max-w-[36px] object-cover object-left" width="146" height="32">
    </div>

    <nav class="flex-1 space-y-6 overflow-y-auto px-3 py-4">
      <div v-for="group in groups" :key="group.title">
        <p
          v-if="!props.collapsed"
          class="px-3 pb-2 text-[11px] font-medium uppercase tracking-widest text-neutral-500"
        >
          {{ group.title }}
        </p>
        <ul class="space-y-1">
          <li v-for="item in group.items" :key="item.to">
            <NuxtLink
              :to="item.to"
              class="flex items-center gap-3 rounded-md px-3 py-2 text-sm text-neutral-300 transition-colors hover:bg-white/5"
              active-class="bg-white/[0.07] text-white"
              :title="props.collapsed ? item.label : undefined"
            >
              <BaseIcon :name="item.icon" class="h-[18px] w-[18px] shrink-0" />
              <span v-if="!props.collapsed">{{ item.label }}</span>
            </NuxtLink>
          </li>
        </ul>
      </div>
    </nav>
  </aside>
</template>
