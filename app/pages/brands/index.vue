<script setup lang="ts">
import type { Brand } from '@shared/types'
useHead({ title: '7Carbon — Марки' })
const api = useApi()
const { data } = await useAsyncData('dash-brands', async () => (await api.get<Brand[]>('/brands')).data)
</script>
<template>
  <div class="space-y-6">
    <h1 class="font-display text-2xl font-semibold tracking-tight">Марки автомобилей</h1>
    <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      <div v-for="b in data" :key="b.id" class="card flex items-center justify-between p-5">
        <div>
          <p class="font-medium">{{ b.name }}</p>
          <p class="text-sm text-neutral-500">{{ b.country }}</p>
        </div>
        <span class="badge bg-white/5 text-neutral-300">{{ b.models?.length ?? 0 }} моделей</span>
      </div>
    </div>
  </div>
</template>
