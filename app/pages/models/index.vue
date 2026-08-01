<script setup lang="ts">
import type { Brand } from '@shared/types'
useHead({ title: '7Carbon — Модели' })
const api = useApi()
const { data } = await useAsyncData('dash-models', async () => (await api.get<Brand[]>('/brands')).data)
</script>
<template>
  <div class="space-y-6">
    <h1 class="font-display text-2xl font-semibold tracking-tight">Модели</h1>
    <div v-for="b in data" :key="b.id" class="card p-5">
      <p class="mb-3 font-medium">{{ b.name }}</p>
      <div class="flex flex-wrap gap-2">
        <span v-for="m in b.models" :key="m.id" class="badge border border-line px-3 py-1 text-neutral-300">{{ m.name }}</span>
        <span v-if="!b.models?.length" class="text-sm text-neutral-500">Нет моделей</span>
      </div>
    </div>
  </div>
</template>
