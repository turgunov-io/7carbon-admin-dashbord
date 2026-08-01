<script setup lang="ts">
definePageMeta({ layout: 'auth' })
useHead({ title: '7Carbon — Вход' })

const auth = useAuthStore()
const route = useRoute()

const email = ref('admin@7carbon.uz')
const password = ref('')
const error = ref('')
const loading = ref(false)

async function submit() {
  error.value = ''
  loading.value = true
  try {
    await auth.login(email.value, password.value)
    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/'
    await navigateTo(redirect)
  } catch (err) {
    const e = err as { statusMessage?: string }
    error.value = e.statusMessage ?? 'Не удалось войти'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="relative z-10 w-full max-w-sm">
    <div class="mb-8">
      <img src="/logo.svg" alt="7 Carbon" class="h-10 w-auto" width="182" height="40">
      <p class="mt-3 text-xs text-neutral-500">Панель управления</p>
    </div>

    <div class="card p-6">
      <h1 class="mb-1 text-xl font-semibold">Вход в систему</h1>
      <p class="mb-6 text-sm text-neutral-400">Введите учётные данные администратора</p>

      <form class="space-y-4" @submit.prevent="submit">
        <div>
          <label class="mb-1.5 block text-sm text-neutral-300" for="email">Email</label>
          <input id="email" v-model="email" type="email" autocomplete="username" class="input" required />
        </div>
        <div>
          <label class="mb-1.5 block text-sm text-neutral-300" for="password">Пароль</label>
          <input id="password" v-model="password" type="password" autocomplete="current-password" class="input" required />
        </div>

        <p v-if="error" class="rounded-md bg-danger/10 px-3 py-2 text-sm text-danger">{{ error }}</p>

        <button type="submit" class="btn-primary w-full" :disabled="loading">
          <span v-if="loading">Вход…</span>
          <span v-else>Войти</span>
        </button>
      </form>
    </div>
  </div>
</template>
