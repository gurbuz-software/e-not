import { defineStore } from 'pinia'
import { supabase } from '../lib/supabase'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    loading: false,
    error: null,
    initialized: false,
    listenerSetup: false
  }),

  getters: {
    isAuthenticated: (state) => !!state.user
  },

  actions: {
    async login(email, password) {
      this.loading = true
      this.error = null

      try {
        const { data, error } = await supabase.auth.signInWithPassword({
          email,
          password
        })

        if (error) throw error

        this.user = data.user
        return { success: true }
      } catch (error) {
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    async register(email, password) {
      this.loading = true
      this.error = null

      try {
        const { data, error } = await supabase.auth.signUp({
          email,
          password
        })

        if (error) throw error

        // Don't set user immediately - user needs to verify email first
        // this.user = data.user
        return { success: true, user: data.user }
      } catch (error) {
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    async logout() {
      this.loading = true
      this.error = null
      
      try {
        console.log('Attempting logout...')
        const { error } = await supabase.auth.signOut()
        
        if (error) {
          console.error('Logout error:', error)
          throw error
        }
        
        console.log('Logout successful')
        this.user = null
        return { success: true }
      } catch (error) {
        console.error('Error during logout:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    async checkAuth() {
      try {
        const { data: { session } } = await supabase.auth.getSession()
        this.user = session?.user || null
        this.initialized = true
        
        // Listen for auth changes (only setup once)
        if (!this.listenerSetup) {
          this.listenerSetup = true
          supabase.auth.onAuthStateChange((event, session) => {
            this.user = session?.user || null
          })
        }
      } catch (error) {
        console.error('Error checking auth:', error)
        this.user = null
        this.initialized = true
      }
    }
  }
})
