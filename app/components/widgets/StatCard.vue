<script setup lang="ts">
defineProps<{
  label: string
  value: string | number
  icon: string
  accent?: boolean
}>()
</script>

<template>
  <div class="card p-5">
    <div class="flex items-center justify-between">
      <span class="text-sm text-neutral-400">{{ label }}</span>
      <div
        class="flex h-9 w-9 items-center justify-center rounded-md"
        :class="accent ? 'bg-accent/15 text-accent' : 'bg-white/5 text-neutral-300'"
      >
        <BaseIcon :name="icon" class="h-[18px] w-[18px]" />
      </div>
    </div>
    <p class="mt-3 font-display text-3xl font-semibold tracking-tight">{{ value }}</p>
  </div>
</template>
