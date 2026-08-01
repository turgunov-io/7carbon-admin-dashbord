<script setup lang="ts">
import type { Consultation } from '@shared/types'
import { CONSULTATION_STATUSES } from '@shared/constants'

useHead({ title: '7Carbon — Заявки' })

const api = useApi()
const status = ref<string>('')
const search = ref('')
const page = ref(1)

const statusLabels: Record<string, string> = {
  NEW: 'Новая',
  CONTACTED: 'Связались',
  IN_PROGRESS: 'В работе',
  COMPLETED: 'Завершена',
  CANCELLED: 'Отменена',
}
const statusColor: Record<string, string> = {
  NEW: 'bg-info/15 text-info',
  CONTACTED: 'bg-warning/15 text-warning',
  IN_PROGRESS: 'bg-accent-blue/15 text-accent-blue',
  COMPLETED: 'bg-success/15 text-success',
  CANCELLED: 'bg-neutral-500/15 text-neutral-400',
}

const { data, refresh, pending } = await useAsyncData(
  'consultations',
  async () => {
    const res = await api.get<Consultation[]>('/consultations', {
      status: status.value || undefined,
      search: search.value || undefined,
      page: page.value,
    })
    return res
  },
  { watch: [status, page] },
)

async function changeStatus(id: string, next: string) {
  await api.patch(`/consultations/${id}`, { status: next })
  await refresh()
}

let searchTimer: ReturnType<typeof setTimeout>
watch(search, () => {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    page.value = 1
    refresh()
  }, 350)
})
</script>

<template>
  <div class="space-y-6">
    <div class="flex flex-wrap items-center justify-between gap-4">
      <div>
        <h1 class="font-display text-2xl font-semibold tracking-tight">Заявки на консультацию</h1>
        <p class="mt-1 text-sm text-neutral-400">CRM: {{ data?.meta?.total ?? 0 }} заявок</p>
      </div>
      <input v-model="search" placeholder="Поиск по имени, телефону…" class="input max-w-xs" />
    </div>

    <div class="flex flex-wrap gap-2">
      <button
        class="badge border border-line px-3 py-1.5"
        :class="status === '' ? 'bg-white/10 text-white' : 'text-neutral-400'"
        @click="status = ''; page = 1"
      >
        Все
      </button>
      <button
        v-for="s in CONSULTATION_STATUSES"
        :key="s"
        class="badge border border-line px-3 py-1.5"
        :class="status === s ? 'bg-white/10 text-white' : 'text-neutral-400'"
        @click="status = s; page = 1"
      >
        {{ statusLabels[s] }}
      </button>
    </div>

    <div class="card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="border-b border-line text-left text-neutral-500">
            <tr>
              <th class="px-5 py-3 font-medium">Клиент</th>
              <th class="px-5 py-3 font-medium">Телефон</th>
              <th class="px-5 py-3 font-medium">Автомобиль</th>
              <th class="px-5 py-3 font-medium">Интерес</th>
              <th class="px-5 py-3 font-medium">Статус</th>
              <th class="px-5 py-3 font-medium">Дата</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-line">
            <tr v-for="c in data?.data" :key="c.id" class="hover:bg-white/[0.02]">
              <td class="px-5 py-3">
                <p class="font-medium">{{ c.fullName }}</p>
                <p v-if="c.telegram" class="text-xs text-neutral-500">{{ c.telegram }}</p>
              </td>
              <td class="px-5 py-3 text-neutral-300">{{ c.phone }}</td>
              <td class="px-5 py-3 text-neutral-400">
                {{ [c.carBrand, c.carModel, c.year].filter(Boolean).join(' · ') || '—' }}
              </td>
              <td class="px-5 py-3 text-neutral-400">
                {{ c.product?.title ?? c.service?.title ?? '—' }}
              </td>
              <td class="px-5 py-3">
                <select
                  :value="c.status"
                  class="input py-1 text-xs"
                  :class="statusColor[c.status]"
                  @change="changeStatus(c.id, ($event.target as HTMLSelectElement).value)"
                >
                  <option v-for="s in CONSULTATION_STATUSES" :key="s" :value="s">
                    {{ statusLabels[s] }}
                  </option>
                </select>
              </td>
              <td class="px-5 py-3 text-neutral-500">
                {{ new Date(c.createdAt).toLocaleDateString('ru-RU') }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <p v-if="!pending && !data?.data?.length" class="py-12 text-center text-sm text-neutral-500">
        Заявок не найдено
      </p>
    </div>
  </div>
</template>
