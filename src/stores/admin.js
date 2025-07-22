import { defineStore } from 'pinia'
import { supabase } from '../lib/supabase'

export const useAdminStore = defineStore('admin', {
  state: () => ({
    isAdmin: false,
    allNotes: [],
    allUsers: [],
    loading: false,
    error: null
  }),

  getters: {
    // Get notes by user email
    getNotesByUser: (state) => (userEmail) => {
      return state.allNotes.filter(note => note.user_email === userEmail)
    },

    // Get total notes count
    totalNotesCount: (state) => state.allNotes.length,

    // Get total users count
    totalUsersCount: (state) => state.allUsers.length,

    // Get admin users
    adminUsers: (state) => state.allUsers.filter(user => user.is_admin),

    // Get regular users
    regularUsers: (state) => state.allUsers.filter(user => !user.is_admin)
  },

  actions: {
    // Check if current user is admin
    async checkAdminStatus() {
      try {
        const { data, error } = await supabase.rpc('is_current_user_admin')
        
        if (error) throw error
        
        this.isAdmin = data || false
        return this.isAdmin
      } catch (error) {
        console.error('Error checking admin status:', error)
        this.isAdmin = false
        return false
      }
    },

    // Get all notes (admin only)
    async fetchAllNotes() {
      if (!this.isAdmin) {
        throw new Error('Admin privileges required')
      }

      this.loading = true
      this.error = null

      try {
        const { data, error } = await supabase.rpc('get_all_notes_admin')
        
        if (error) throw error

        this.allNotes = data || []
        return { success: true, notes: this.allNotes }
      } catch (error) {
        console.error('Error fetching all notes:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    // Get all users (admin only)
    async fetchAllUsers() {
      if (!this.isAdmin) {
        throw new Error('Admin privileges required')
      }

      this.loading = true
      this.error = null

      try {
        const { data, error } = await supabase.rpc('get_all_users_admin')
        
        if (error) throw error

        this.allUsers = data || []
        return { success: true, users: this.allUsers }
      } catch (error) {
        console.error('Error fetching all users:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    // Update note as admin
    async adminUpdateNote(noteId, updates) {
      if (!this.isAdmin) {
        throw new Error('Admin privileges required')
      }

      this.loading = true
      this.error = null

      try {
        const { data, error } = await supabase.rpc('admin_update_note', {
          p_note_id: noteId,
          p_title: updates.title || null,
          p_content: updates.content || null,
          p_content_text: updates.content_text || null,
          p_is_favorite: updates.is_favorite !== undefined ? updates.is_favorite : null,
          p_is_archived: updates.is_archived !== undefined ? updates.is_archived : null,
          p_folder_id: updates.folder_id || null,
          p_tags: updates.tags || null
        })

        if (error) throw error

        // Update local state
        const noteIndex = this.allNotes.findIndex(note => note.note_id === noteId)
        if (noteIndex !== -1) {
          // Update the note in local state
          Object.assign(this.allNotes[noteIndex], {
            note_title: updates.title || this.allNotes[noteIndex].note_title,
            note_content: updates.content || this.allNotes[noteIndex].note_content,
            note_content_text: updates.content_text || this.allNotes[noteIndex].note_content_text,
            note_is_favorite: updates.is_favorite !== undefined ? updates.is_favorite : this.allNotes[noteIndex].note_is_favorite,
            note_is_archived: updates.is_archived !== undefined ? updates.is_archived : this.allNotes[noteIndex].note_is_archived,
            note_folder_id: updates.folder_id || this.allNotes[noteIndex].note_folder_id,
            note_tags: updates.tags || this.allNotes[noteIndex].note_tags,
            note_updated_at: new Date().toISOString()
          })
        }

        return { success: true, data }
      } catch (error) {
        console.error('Error updating note as admin:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    // Delete note as admin
    async adminDeleteNote(noteId) {
      if (!this.isAdmin) {
        throw new Error('Admin privileges required')
      }

      this.loading = true
      this.error = null

      try {
        const { data, error } = await supabase.rpc('admin_delete_note', {
          p_note_id: noteId
        })

        if (error) throw error

        // Remove from local state
        this.allNotes = this.allNotes.filter(note => note.note_id !== noteId)

        return { success: true, data }
      } catch (error) {
        console.error('Error deleting note as admin:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    // Make user admin
    async makeUserAdmin(userId) {
      if (!this.isAdmin) {
        throw new Error('Admin privileges required')
      }

      try {
        const { error } = await supabase
          .from('user_profiles')
          .update({ is_admin: true })
          .eq('id', userId)

        if (error) throw error

        // Update local state
        const userIndex = this.allUsers.findIndex(user => user.user_id === userId)
        if (userIndex !== -1) {
          this.allUsers[userIndex].is_admin = true
        }

        return { success: true }
      } catch (error) {
        console.error('Error making user admin:', error)
        return { success: false, error: error.message }
      }
    },

    // Remove admin privileges
    async removeAdminPrivileges(userId) {
      if (!this.isAdmin) {
        throw new Error('Admin privileges required')
      }

      try {
        const { error } = await supabase
          .from('user_profiles')
          .update({ is_admin: false })
          .eq('id', userId)

        if (error) throw error

        // Update local state
        const userIndex = this.allUsers.findIndex(user => user.user_id === userId)
        if (userIndex !== -1) {
          this.allUsers[userIndex].is_admin = false
        }

        return { success: true }
      } catch (error) {
        console.error('Error removing admin privileges:', error)
        return { success: false, error: error.message }
      }
    },

    // Initialize admin data
    async initializeAdminData() {
      const isAdmin = await this.checkAdminStatus()
      
      if (isAdmin) {
        await Promise.all([
          this.fetchAllNotes(),
          this.fetchAllUsers()
        ])
      }
      
      return isAdmin
    },

    // Clear admin data
    clearAdminData() {
      this.isAdmin = false
      this.allNotes = []
      this.allUsers = []
      this.error = null
    }
  }
})
