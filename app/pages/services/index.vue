<script setup lang="ts">
import type { Service } from '@shared/types'

useHead({ title: '7Carbon — Услуги' })
const api = useApi()
const { data } = await useAsyncData('dash-services', async () => (await api.get<Service[]>('/services')).data)
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="font-display text-2xl font-semibold tracking-tight">Услуги</h1>
        <p class="mt-1 text-sm text-neutral-400">{{ data?.length ?? 0 }} услуг</p>
      </div>
    </div>

    <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      <div v-for="s in data" :key="s.id" class="card p-6">
        <div class="mb-3 flex items-center justify-between">
          <span class="badge bg-success/15 text-success">{{ s.status }}</span>
          <span class="text-xs text-neutral-500">{{ s.gallery.length }} фото</span>
        </div>
        <h3 class="font-medium">{{ s.serviceType }}</h3>
        <p v-if="s.summary" class="mt-2 line-clamp-3 text-sm text-neutral-400">{{ s.summary }}</p>
      </div>
    </div>
  </div>
</template>
