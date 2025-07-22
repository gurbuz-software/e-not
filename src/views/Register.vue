<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <!-- Header with Language and Theme toggles -->
      <div class="flex justify-end space-x-2 mb-4">
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
      </div>

      <!-- Register Form -->
      <div class="bg-white dark:bg-gray-800 shadow-xl rounded-lg p-8">
        <div class="text-center">
          <h2 class="text-3xl font-extrabold text-gray-900 dark:text-white">
            {{ $t('auth.registerTitle') }}
          </h2>
          <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
            {{ $t('auth.registerSubtitle') }}
          </p>
        </div>

        <form class="mt-8 space-y-6" @submit.prevent="handleRegister">
          <!-- Error message -->
          <div v-if="error" class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-600 dark:text-red-400 px-4 py-3 rounded-md text-sm">
            {{ error }}
          </div>
          
          <!-- Success message -->
          <div v-if="successMessage" class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 text-green-600 dark:text-green-400 px-4 py-3 rounded-md text-sm">
            <div class="flex items-center">
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <div>
                <p class="font-medium">{{ $t('auth.emailVerificationSent') }}</p>
                <p class="text-sm mt-1">{{ $t('auth.checkEmailVerification') }}</p>
              </div>
            </div>
          </div>

          <div class="space-y-4">
            <!-- Email -->
            <div>
              <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                {{ $t('auth.email') }}
              </label>
              <input
                id="email"
                v-model="email"
                type="email"
                required
                class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-white bg-white dark:bg-gray-700 focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm"
                :class="{ 'border-red-300 dark:border-red-600': emailError }"
                :placeholder="$t('auth.email')"
              >
              <p v-if="emailError" class="mt-1 text-sm text-red-600 dark:text-red-400">
                {{ emailError }}
              </p>
            </div>

            <!-- Password -->
            <div>
              <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                {{ $t('auth.password') }}
              </label>
              <input
                id="password"
                v-model="password"
                type="password"
                required
                class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-white bg-white dark:bg-gray-700 focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm"
                :class="{ 'border-red-300 dark:border-red-600': passwordError }"
                :placeholder="$t('auth.password')"
              >
              <p v-if="passwordError" class="mt-1 text-sm text-red-600 dark:text-red-400">
                {{ passwordError }}
              </p>
            </div>

            <!-- Confirm Password -->
            <div>
              <label for="confirmPassword" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                {{ $t('auth.confirmPassword') }}
              </label>
              <input
                id="confirmPassword"
                v-model="confirmPassword"
                type="password"
                required
                class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-white bg-white dark:bg-gray-700 focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm"
                :class="{ 'border-red-300 dark:border-red-600': confirmPasswordError }"
                :placeholder="$t('auth.confirmPassword')"
              >
              <p v-if="confirmPasswordError" class="mt-1 text-sm text-red-600 dark:text-red-400">
                {{ confirmPasswordError }}
              </p>
            </div>
          </div>

          <!-- Register button -->
          <div>
            <button
              type="submit"
              :disabled="authStore.loading"
              class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <span v-if="!authStore.loading">{{ $t('auth.register') }}</span>
              <span v-else class="flex items-center">
                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                {{ $t('auth.register') }}
              </span>
            </button>
          </div>

          <!-- Login link -->
          <div class="text-center">
            <span class="text-sm text-gray-600 dark:text-gray-400">
              {{ $t('auth.hasAccount') }}
            </span>
            <router-link
              to="/login"
              class="ml-1 font-medium text-primary-600 hover:text-primary-500 transition-colors"
            >
              {{ $t('auth.login') }}
            </router-link>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useThemeStore } from '../stores/theme'
import { useI18n } from 'vue-i18n'

const router = useRouter()
const authStore = useAuthStore()
const themeStore = useThemeStore()
const { t, locale } = useI18n()

const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const error = ref('')
const successMessage = ref(false)
const emailError = ref('')
const passwordError = ref('')
const confirmPasswordError = ref('')

const validateForm = () => {
  emailError.value = ''
  passwordError.value = ''
  confirmPasswordError.value = ''
  
  if (!email.value) {
    emailError.value = t('auth.emailRequired')
    return false
  }
  
  if (!password.value) {
    passwordError.value = t('auth.passwordRequired')
    return false
  }
  
  if (password.value !== confirmPassword.value) {
    confirmPasswordError.value = t('auth.passwordMismatch')
    return false
  }
  
  return true
}

const handleRegister = async () => {
  if (!validateForm()) return
  
  error.value = ''
  successMessage.value = false
  
  const result = await authStore.register(email.value, password.value)
  
  if (result.success) {
    // Show success message instead of redirecting
    successMessage.value = true
    // Clear form fields
    email.value = ''
    password.value = ''
    confirmPassword.value = ''
  } else {
    error.value = result.error || t('auth.registerError')
  }
}

const toggleTheme = () => {
  themeStore.toggleTheme()
}

const toggleLanguage = () => {
  locale.value = locale.value === 'tr' ? 'en' : 'tr'
  localStorage.setItem('locale', locale.value)
}
</script>
