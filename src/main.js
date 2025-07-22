import { createApp } from 'vue'
import { createPinia } from 'pinia'
import './style.css'
import App from './App.vue'
import router from './router'
import i18n from './i18n'
import { useThemeStore } from './stores/theme'
import { useAuthStore } from './stores/auth'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(i18n)

// Initialize theme
const themeStore = useThemeStore()
themeStore.initTheme()

// Initialize authentication (will be handled by router guard for subsequent navigation)
const authStore = useAuthStore()
authStore.checkAuth()

app.mount('#app')
