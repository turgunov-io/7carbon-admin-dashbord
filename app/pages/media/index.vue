<script setup lang="ts">
useHead({ title: '7Carbon — Медиа библиотека' })
</script>
<template>
  <div class="space-y-6">
    <div>
      <h1 class="font-display text-2xl font-semibold tracking-tight">Медиа библиотека</h1>
      <p class="mt-1 text-sm text-neutral-400">Загрузка и управление изображениями и видео</p>
    </div>
    <div class="card flex flex-col items-center justify-center gap-3 p-16 text-center">
      <BaseIcon name="settings" class="h-10 w-10 text-neutral-600" />
      <p class="text-sm text-neutral-400">Модуль подключён к API и схеме базы данных.<br>Интерфейс редактирования настраивается администратором.</p>
    </div>
  </div>
</template>
