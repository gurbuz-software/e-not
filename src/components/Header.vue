<template>
<header class="fixed top-0 left-0 right-0 z-50 bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between items-center h-16">
        <!-- Logo -->
        <div class="flex-shrink-0">
          <h1 class="text-xl font-bold text-gray-900 dark:text-white">
            {{ $t('app.title') }}
          </h1>
        </div>

        <!-- Actions -->
        <div class="flex items-center space-x-4">
          <!-- Admin Panel Link -->
          <router-link
            v-if="adminStore.isAdmin"
            to="/admin"
            class="inline-flex items-center px-3 py-1 rounded-md text-sm font-medium bg-purple-100 dark:bg-purple-900 text-purple-800 dark:text-purple-200 hover:bg-purple-200 dark:hover:bg-purple-800 transition-colors"
            title="Admin Panel"
          >
            <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
            </svg>
            Admin Panel
          </router-link>

          <!-- Language Toggle -->
          <button
            @click="toggleLanguage"
            class="p-2 rounded-md text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
            :title="$t('language.change')"
          >
            <span class="text-sm font-medium">
              {{ $i18n.locale === 'tr' ? 'TR' : 'EN' }}
            </span>
          </button>

          <!-- Theme Toggle -->
          <button
            @click="toggleTheme"
            class="p-2 rounded-md text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
            :title="$t('theme.toggle')"
          >
            <svg
              v-if="themeStore.isDark"
              class="w-5 h-5"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"
              />
            </svg>
            <svg
              v-else
              class="w-5 h-5"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
              />
            </svg>
          </button>

          <!-- User Menu -->
          <div v-if="authStore.isAuthenticated" class="relative">
            <button
              @click="showUserMenu = !showUserMenu"
              class="flex items-center text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            >
              <div class="w-8 h-8 bg-primary-500 rounded-full flex items-center justify-center text-white font-medium">
                {{ authStore.user?.email?.[0]?.toUpperCase() }}
              </div>
            </button>

            <!-- User dropdown -->
            <div
              v-if="showUserMenu"
              class="absolute right-0 mt-2 w-48 bg-white dark:bg-gray-800 rounded-md shadow-lg py-1 z-10 border border-gray-200 dark:border-gray-700"
            >
              <button
                @click="logout"
                class="w-full text-left px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
              >
                {{ $t('auth.logout') }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useAdminStore } from '../stores/admin'
import { useThemeStore } from '../stores/theme'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const adminStore = useAdminStore()
const themeStore = useThemeStore()
const { locale } = useI18n()
const router = useRouter()

const showUserMenu = ref(false)

const toggleTheme = () => {
  themeStore.toggleTheme()
}

const toggleLanguage = () => {
  locale.value = locale.value === 'tr' ? 'en' : 'tr'
  localStorage.setItem('locale', locale.value)
}

const logout = async () => {
  try {
    console.log('Header: Starting logout...')
    const result = await authStore.logout()
    
    showUserMenu.value = false
    
    if (result.success) {
      console.log('Header: Logout successful, redirecting to login')
      await router.push('/login')
    } else {
      console.error('Header: Logout failed:', result.error)
      // Still redirect to login even if logout had an error
      await router.push('/login')
    }
  } catch (error) {
    console.error('Header: Unexpected error during logout:', error)
    showUserMenu.value = false
    // Force redirect to login page
    await router.push('/login')
  }
}

// Check admin status on mount
onMounted(async () => {
  if (authStore.isAuthenticated) {
    await adminStore.checkAdminStatus()
  }
})

// Close user menu when clicking outside
document.addEventListener('click', (event) => {
  if (!event.target.closest('.relative')) {
    showUserMenu.value = false
  }
})
</script>
