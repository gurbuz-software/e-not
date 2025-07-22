<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
    <div class="flex flex-col items-center">
      <!-- Loading Spinner -->
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mb-4"></div>
      
      <!-- Loading Text -->
      <p class="text-lg text-gray-600 dark:text-gray-400">
        {{ $t('loading.text') }}
      </p>
    </div>
  </div>
</template>

<script setup>
// Loading component for authentication state
</script>
