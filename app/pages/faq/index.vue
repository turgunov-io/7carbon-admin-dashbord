<script setup lang="ts">
import type { FaqItem } from '@shared/types'
useHead({ title: '7Carbon — FAQ' })
const api = useApi()
const { data } = await useAsyncData('dash-faq', async () => (await api.get<FaqItem[]>('/faq')).data)
</script>
<template>
  <div class="space-y-6">
    <h1 class="font-display text-2xl font-semibold tracking-tight">Частые вопросы</h1>
    <div v-if="data?.length" class="space-y-3">
      <div v-for="f in data" :key="f.id" class="card p-5">
        <p class="font-medium">{{ f.question }}</p>
        <p class="mt-2 text-sm text-neutral-400">{{ f.answer }}</p>
      </div>
    </div>
    <div v-else class="card p-12 text-center text-sm text-neutral-500">Вопросов пока нет. Добавьте первый вопрос.</div>
  </div>
</template>
