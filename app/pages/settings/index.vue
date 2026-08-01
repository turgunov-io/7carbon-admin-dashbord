<script setup lang="ts">
import type { SiteSettings } from '@shared/types'

useHead({ title: '7Carbon — Настройки' })
const api = useApi()
const { data } = await useAsyncData('dash-settings', async () => (await api.get<SiteSettings>('/settings')).data)
</script>

<template>
  <div class="max-w-2xl space-y-6">
    <div>
      <h1 class="font-display text-2xl font-semibold tracking-tight">Настройки</h1>
      <p class="mt-1 text-sm text-neutral-400">Контактная информация компании</p>
    </div>

    <div class="card divide-y divide-line">
      <div class="flex items-center justify-between px-5 py-4">
        <span class="text-sm text-neutral-400">Компания</span>
        <span class="font-medium">{{ data?.companyName }}</span>
      </div>
      <div class="flex items-center justify-between px-5 py-4">
        <span class="text-sm text-neutral-400">Телефон</span>
        <span class="font-medium">{{ data?.phone }}</span>
      </div>
      <div class="flex items-center justify-between px-5 py-4">
        <span class="text-sm text-neutral-400">Email</span>
        <span class="font-medium">{{ data?.email }}</span>
      </div>
      <div class="flex items-start justify-between gap-6 px-5 py-4">
        <span class="text-sm text-neutral-400">Адрес</span>
        <span class="text-right font-medium">
          <span v-for="(l, i) in data?.addressLines" :key="i" class="block">{{ l }}</span>
        </span>
      </div>
      <div class="flex items-start justify-between gap-6 px-5 py-4">
        <span class="text-sm text-neutral-400">Часы работы</span>
        <span class="text-right font-medium">
          <span v-for="(l, i) in data?.workSchedule" :key="i" class="block">{{ l }}</span>
        </span>
      </div>
      <div class="flex items-center justify-between px-5 py-4">
        <span class="text-sm text-neutral-400">Язык по умолчанию</span>
        <span class="font-medium uppercase">{{ data?.defaultLanguage }}</span>
      </div>
    </div>
  </div>
</template>
