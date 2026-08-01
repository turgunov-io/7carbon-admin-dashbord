<script setup lang="ts">
import type { Category } from '@shared/types'
useHead({ title: '7Carbon — Категории' })
const api = useApi()
const { data } = await useAsyncData('dash-categories', async () => (await api.get<Category[]>('/categories')).data)
</script>
<template>
  <div class="space-y-6">
    <h1 class="font-display text-2xl font-semibold tracking-tight">Категории</h1>
    <div class="card overflow-hidden">
      <table class="w-full text-sm">
        <thead class="border-b border-line text-left text-neutral-500">
          <tr><th class="px-5 py-3 font-medium">Название</th><th class="px-5 py-3 font-medium">Slug</th><th class="px-5 py-3 font-medium">Товаров</th></tr>
        </thead>
        <tbody class="divide-y divide-line">
          <tr v-for="c in data" :key="c.id" class="hover:bg-white/[0.02]">
            <td class="px-5 py-3 font-medium">{{ c.title }}</td>
            <td class="px-5 py-3 text-neutral-400">{{ c.slug }}</td>
            <td class="px-5 py-3 text-neutral-300">{{ c.productCount }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
