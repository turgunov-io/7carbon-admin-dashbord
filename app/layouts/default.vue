<script setup lang="ts">
// Persisted collapse preference for the sidebar.
const collapsed = useState('sidebar-collapsed', () => false)
</script>

<template>
  <div class="flex min-h-screen bg-bg text-neutral-100">
    <DashboardSidebar :collapsed="collapsed" />
    <div class="flex min-w-0 flex-1 flex-col">
      <DashboardTopbar :collapsed="collapsed" @toggle="collapsed = !collapsed" />
      <main class="flex-1 overflow-y-auto p-6 lg:p-8">
        <slot />
      </main>
    </div>
  </div>
</template>
