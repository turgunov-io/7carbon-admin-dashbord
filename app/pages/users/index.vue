<script setup lang="ts">
useHead({ title: '7Carbon — Пользователи' })
const auth = useAuthStore()
</script>
<template>
  <div class="max-w-2xl space-y-6">
    <h1 class="font-display text-2xl font-semibold tracking-tight">Пользователи</h1>
    <div class="card overflow-hidden">
      <table class="w-full text-sm">
        <thead class="border-b border-line text-left text-neutral-500">
          <tr><th class="px-5 py-3 font-medium">Имя</th><th class="px-5 py-3 font-medium">Email</th><th class="px-5 py-3 font-medium">Роль</th></tr>
        </thead>
        <tbody>
          <tr class="hover:bg-white/[0.02]">
            <td class="px-5 py-3 font-medium">{{ auth.user?.fullName }}</td>
            <td class="px-5 py-3 text-neutral-400">{{ auth.user?.email }}</td>
            <td class="px-5 py-3"><span class="badge bg-accent/15 text-accent">{{ auth.user?.role }}</span></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
