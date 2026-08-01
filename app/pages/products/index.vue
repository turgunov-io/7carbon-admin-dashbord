<script setup lang="ts">
import type { Product } from '@shared/types'

useHead({ title: '7Carbon — Товары' })

const api = useApi()
const search = ref('')
const page = ref(1)

const { data, refresh, pending } = await useAsyncData(
  'admin-products',
  () => api.get<Product[]>('/admin/products', { search: search.value || undefined, page: page.value }),
  { watch: [page] },
)

const statusBadge: Record<string, string> = {
  ACTIVE: 'bg-success/15 text-success',
  DRAFT: 'bg-warning/15 text-warning',
  ARCHIVED: 'bg-neutral-500/15 text-neutral-400',
}

let t: ReturnType<typeof setTimeout>
watch(search, () => {
  clearTimeout(t)
  t = setTimeout(() => { page.value = 1; refresh() }, 350)
})
</script>

<template>
  <div class="space-y-6">
    <div class="flex flex-wrap items-center justify-between gap-4">
      <div>
        <h1 class="font-display text-2xl font-semibold tracking-tight">Товары</h1>
        <p class="mt-1 text-sm text-neutral-400">{{ data?.meta?.total ?? 0 }} позиций в каталоге</p>
      </div>
      <div class="flex gap-3">
        <input v-model="search" placeholder="Поиск товаров…" class="input max-w-xs" />
        <NuxtLink to="/products/new" class="btn-primary shrink-0">
          <BaseIcon name="plus" class="h-4 w-4" /> Создать
        </NuxtLink>
      </div>
    </div>

    <div class="card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="border-b border-line text-left text-neutral-500">
            <tr>
              <th class="px-5 py-3 font-medium">Товар</th>
              <th class="px-5 py-3 font-medium">Бренд</th>
              <th class="px-5 py-3 font-medium">Категория</th>
              <th class="px-5 py-3 font-medium">Цена</th>
              <th class="px-5 py-3 font-medium">Статус</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-line">
            <tr v-for="p in data?.data" :key="p.id" class="hover:bg-white/[0.02]">
              <td class="px-5 py-3">
                <div class="flex items-center gap-3">
                  <img
                    v-if="p.cardImage"
                    :src="p.cardImage"
                    :alt="p.title"
                    loading="lazy"
                    class="h-10 w-14 shrink-0 rounded object-cover"
                  >
                  <div class="h-10 w-14 shrink-0 rounded bg-white/5" v-else />
                  <span class="line-clamp-2 max-w-md font-medium">{{ p.title }}</span>
                </div>
              </td>
              <td class="px-5 py-3 text-neutral-400">{{ p.supplierBrand ?? '—' }}</td>
              <td class="px-5 py-3 text-neutral-400">{{ p.category?.title ?? '—' }}</td>
              <td class="px-5 py-3 text-neutral-300">{{ p.price ?? 'По запросу' }}</td>
              <td class="px-5 py-3">
                <span class="badge" :class="statusBadge[p.status]">{{ p.status }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <p v-if="!pending && !data?.data?.length" class="py-12 text-center text-sm text-neutral-500">
        Товары не найдены
      </p>
    </div>
  </div>
</template>
