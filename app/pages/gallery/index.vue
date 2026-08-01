<script setup lang="ts">
import type { GalleryItem } from '@shared/types'
useHead({ title: '7Carbon — Галерея' })
const api = useApi()
const { data } = await useAsyncData('dash-gallery', async () => (await api.get<GalleryItem[]>('/gallery')).data)
</script>
<template>
  <div class="space-y-6">
    <h1 class="font-display text-2xl font-semibold tracking-tight">Галерея</h1>
    <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
      <div v-for="g in data" :key="g.id" class="aspect-square overflow-hidden rounded-md border border-line bg-surface">
        <img :src="g.image" :alt="g.title ?? ''" loading="lazy" class="h-full w-full object-cover" />
      </div>
    </div>
  </div>
</template>
