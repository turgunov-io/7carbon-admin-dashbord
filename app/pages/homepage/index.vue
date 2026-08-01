<script setup lang="ts">
import type { Homepage } from '@shared/types'
useHead({ title: '7Carbon — Главная' })
const api = useApi()
const { data } = await useAsyncData('dash-homepage', async () => (await api.get<Homepage>('/homepage')).data)
</script>
<template>
  <div class="max-w-3xl space-y-6">
    <h1 class="font-display text-2xl font-semibold tracking-tight">Главная страница</h1>
    <div class="card p-6 space-y-4">
      <div>
        <p class="text-xs uppercase tracking-widest text-neutral-500">Заголовок (RU)</p>
        <p class="mt-1 font-medium">{{ (data?.heroTitle as any)?.ru }}</p>
      </div>
      <div>
        <p class="text-xs uppercase tracking-widest text-neutral-500">Подзаголовок (RU)</p>
        <p class="mt-1 text-neutral-300">{{ (data?.heroSubtitle as any)?.ru }}</p>
      </div>
      <div>
        <p class="text-xs uppercase tracking-widest text-neutral-500">О компании (RU)</p>
        <p class="mt-1 whitespace-pre-line text-sm text-neutral-400">{{ (data?.aboutText as any)?.ru }}</p>
      </div>
    </div>
    <div class="grid grid-cols-2 gap-4 sm:grid-cols-4">
      <div v-for="(m, i) in (data?.metrics as any[])" :key="i" class="card p-5 text-center">
        <p class="font-display text-3xl font-semibold">{{ m.value }}</p>
        <p class="mt-1 text-sm text-neutral-400">{{ m.label?.ru }}</p>
      </div>
    </div>
  </div>
</template>
