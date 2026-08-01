<script setup lang="ts">
import type { Review } from '@shared/types'
useHead({ title: '7Carbon — Отзывы' })
const api = useApi()
const { data } = await useAsyncData('dash-reviews', async () => (await api.get<Review[]>('/reviews')).data)
</script>
<template>
  <div class="space-y-6">
    <h1 class="font-display text-2xl font-semibold tracking-tight">Отзывы</h1>
    <div v-if="data?.length" class="grid gap-4 sm:grid-cols-2">
      <div v-for="r in data" :key="r.id" class="card p-5">
        <p class="font-medium">{{ r.customer }}</p>
        <p class="mt-2 text-sm text-neutral-400">{{ r.text }}</p>
      </div>
    </div>
    <div v-else class="card p-12 text-center text-sm text-neutral-500">Отзывов пока нет. Добавьте первый отзыв.</div>
  </div>
</template>
