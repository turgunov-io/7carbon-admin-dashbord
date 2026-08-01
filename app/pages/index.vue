<script setup lang="ts">
useHead({ title: '7Carbon — Дашборд' })

interface Stats {
  totals: { products: number; services: number; categories: number; brands: number; media: number; gallery: number }
  consultations: { byStatus: Record<string, number>; todayCount: number; total: number }
  recentConsultations: { id: string; fullName: string; phone: string; status: string; createdAt: string }[]
}

const api = useApi()
const { data } = await useAsyncData('admin-stats', async () => (await api.get<Stats>('/admin/stats')).data)

const statusLabels: Record<string, string> = {
  NEW: 'Новая',
  CONTACTED: 'Связались',
  IN_PROGRESS: 'В работе',
  COMPLETED: 'Завершена',
  CANCELLED: 'Отменена',
}
</script>

<template>
  <div class="space-y-8">
    <div>
      <h1 class="font-display text-2xl font-semibold tracking-tight">Дашборд</h1>
      <p class="mt-1 text-sm text-neutral-400">Обзор активности 7Carbon</p>
    </div>

    <div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
      <StatCard label="Заявки сегодня" :value="data?.consultations.todayCount ?? 0" icon="inbox" accent />
      <StatCard label="Всего заявок" :value="data?.consultations.total ?? 0" icon="inbox" />
      <StatCard label="Товары" :value="data?.totals.products ?? 0" icon="box" />
      <StatCard label="Услуги" :value="data?.totals.services ?? 0" icon="wrench" />
    </div>

    <div class="grid gap-6 lg:grid-cols-3">
      <div class="card p-6 lg:col-span-2">
        <div class="mb-4 flex items-center justify-between">
          <h2 class="text-lg font-medium">Последние заявки</h2>
          <NuxtLink to="/consultations" class="text-sm text-accent hover:underline">Все заявки →</NuxtLink>
        </div>
        <div v-if="data?.recentConsultations.length" class="divide-y divide-line">
          <div
            v-for="c in data.recentConsultations"
            :key="c.id"
            class="flex items-center justify-between py-3"
          >
            <div>
              <p class="font-medium">{{ c.fullName }}</p>
              <p class="text-sm text-neutral-500">{{ c.phone }}</p>
            </div>
            <span class="badge bg-white/5 text-neutral-300">{{ statusLabels[c.status] ?? c.status }}</span>
          </div>
        </div>
        <p v-else class="py-8 text-center text-sm text-neutral-500">Пока нет заявок</p>
      </div>

      <div class="card p-6">
        <h2 class="mb-4 text-lg font-medium">Статусы заявок</h2>
        <div class="space-y-3">
          <div
            v-for="(label, key) in statusLabels"
            :key="key"
            class="flex items-center justify-between text-sm"
          >
            <span class="text-neutral-400">{{ label }}</span>
            <span class="font-medium">{{ data?.consultations.byStatus[key] ?? 0 }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
