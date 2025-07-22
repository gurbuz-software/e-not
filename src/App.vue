<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900">
    <!-- Loading screen while auth initializes -->
    <Loading v-if="!authStore.initialized" />
    
    <!-- App content once auth is initialized -->
    <template v-else>
      <!-- Header for authenticated users only -->
      <Header v-if="authStore.isAuthenticated && !isAuthRoute" />
      
      <!-- Main content -->
      <main :class="{
        'pt-0': isAuthRoute || !authStore.isAuthenticated,
        'pt-16': authStore.isAuthenticated && !isAuthRoute
      }">
        <router-view />
      </main>
    </template>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from './stores/auth'
import Header from './components/Header.vue'
import Loading from './components/Loading.vue'

const route = useRoute()
const authStore = useAuthStore()

// Check if current route is an auth route (login/register)
const isAuthRoute = computed(() => {
  return ['Login', 'Register'].includes(route.name)
})

// Authentication is handled by router guard
</script>
