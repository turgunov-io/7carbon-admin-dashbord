<script setup lang="ts">
// Root shell. Layouts drive the chrome; NuxtPage renders the active route.
useHead({
  bodyAttrs: { class: 'bg-bg' },
})
</script>

<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>
