<script setup lang="ts">
/** Topbar: sidebar toggle, breadcrumbs, search, notifications, user menu. */
defineProps<{ collapsed: boolean }>()
const emit = defineEmits<{ toggle: [] }>()

const auth = useAuthStore()
const route = useRoute()

// Derive breadcrumb from the current path segments.
const crumbs = computed(() =>
  route.path.split('/').filter(Boolean).map((seg) => seg.charAt(0).toUpperCase() + seg.slice(1)),
)
</script>

<template>
  <header class="flex h-[72px] items-center gap-4 border-b border-line bg-bg/80 px-5 backdrop-blur">
    <button class="btn-ghost h-9 w-9 p-0" aria-label="Меню" @click="emit('toggle')">
      <BaseIcon name="menu" class="h-5 w-5" />
    </button>

    <nav class="flex items-center gap-2 text-sm text-neutral-400" aria-label="Хлебные крошки">
      <NuxtLink to="/" class="hover:text-white">7Carbon</NuxtLink>
      <template v-for="(c, i) in crumbs" :key="i">
        <BaseIcon name="chevron" class="h-3.5 w-3.5 text-neutral-600" />
        <span :class="i === crumbs.length - 1 ? 'text-white' : ''">{{ c }}</span>
      </template>
    </nav>

    <div class="ml-auto flex items-center gap-2">
      <button class="btn-ghost h-9 w-9 p-0" aria-label="Уведомления">
        <BaseIcon name="bell" class="h-5 w-5" />
      </button>
      <div class="mx-1 h-6 w-px bg-line" />
      <div class="flex items-center gap-3">
        <div class="text-right">
          <p class="text-sm font-medium leading-tight">{{ auth.user?.fullName ?? '—' }}</p>
          <p class="text-xs leading-tight text-neutral-500">{{ auth.user?.role }}</p>
        </div>
        <div class="flex h-9 w-9 items-center justify-center rounded-full bg-accent/20 text-sm font-semibold text-accent">
          {{ auth.user?.fullName?.charAt(0) ?? 'A' }}
        </div>
        <button class="btn-ghost h-9 w-9 p-0" aria-label="Выйти" @click="auth.logout()">
          <BaseIcon name="logout" class="h-5 w-5" />
        </button>
      </div>
    </div>
  </header>
</template>
