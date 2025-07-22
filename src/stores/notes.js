import { defineStore } from 'pinia'
import { supabase } from '../lib/supabase'

export const useNotesStore = defineStore('notes', {
  state: () => ({
    notes: [],
    folders: [],
    loading: false,
    error: null,
    currentNote: null,
    searchQuery: ''
  }),

  getters: {
    filteredNotes: (state) => {
      if (!state.searchQuery) return state.notes
      return state.notes.filter(note => 
        note.title.toLowerCase().includes(state.searchQuery.toLowerCase()) ||
        note.content_text?.toLowerCase().includes(state.searchQuery.toLowerCase())
      )
    },

    favoriteNotes: (state) => {
      return state.notes.filter(note => note.is_favorite)
    },

    recentNotes: (state) => {
      return [...state.notes]
        .sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at))
        .slice(0, 5)
    }
  },

  actions: {
    async fetchNotes() {
      this.loading = true
      this.error = null

      try {
        const { data, error } = await supabase
          .from('notes')
          .select('*')
          .eq('is_archived', false)
          .order('updated_at', { ascending: false })

        if (error) throw error

        this.notes = data || []
      } catch (error) {
        console.error('Error fetching notes:', error)
        this.error = error.message
      } finally {
        this.loading = false
      }
    },

    async fetchFolders() {
      try {
        const { data, error } = await supabase
          .from('folders')
          .select('*')
          .order('name')

        if (error) throw error

        this.folders = data || []
      } catch (error) {
        console.error('Error fetching folders:', error)
        this.error = error.message
      }
    },

    async createNote(noteData = {}) {
      this.loading = true
      this.error = null

      try {
        // Get current user ID
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) {
          throw new Error('User not authenticated')
        }
        
        const insertData = {
          user_id: user.id, // Add user_id field
          title: noteData.title || 'Untitled Note',
          content: noteData.content || { type: 'doc', content: [] },
          content_text: noteData.content_text || '',
          folder_id: noteData.folder_id || null,
          tags: noteData.tags || [],
          is_favorite: false,
          is_archived: false
        }
        
        const { data, error } = await supabase
          .from('notes')
          .insert(insertData)
          .select()
          .single()

        if (error) throw error

        this.notes.unshift(data)
        return { success: true, note: data }
      } catch (error) {
        console.error('Error creating note:', error)
        console.error('Error details:', error.message, error.code, error.details)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    async updateNote(noteId, updates) {
      this.loading = true
      this.error = null

      try {
        const { data, error } = await supabase
          .from('notes')
          .update(updates)
          .eq('id', noteId)
          .select()
          .single()

        if (error) throw error

        const index = this.notes.findIndex(note => note.id === noteId)
        if (index !== -1) {
          this.notes[index] = { ...this.notes[index], ...data }
        }

        return { success: true, note: data }
      } catch (error) {
        console.error('Error updating note:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    async deleteNote(noteId) {
      this.loading = true
      this.error = null

      try {
        const { error } = await supabase
          .from('notes')
          .delete()
          .eq('id', noteId)

        if (error) throw error

        this.notes = this.notes.filter(note => note.id !== noteId)
        return { success: true }
      } catch (error) {
        console.error('Error deleting note:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    async toggleFavorite(noteId) {
      const note = this.notes.find(n => n.id === noteId)
      if (!note) return

      return await this.updateNote(noteId, { is_favorite: !note.is_favorite })
    },

    async createFolder(name, description = '', color = '#6366f1') {
      try {
        // Get current user ID
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) {
          throw new Error('User not authenticated')
        }
        
        const { data, error } = await supabase
          .from('folders')
          .insert({
            user_id: user.id, // Add user_id field
            name,
            description,
            color
          })
          .select()
          .single()

        if (error) throw error

        this.folders.push(data)
        return { success: true, folder: data }
      } catch (error) {
        console.error('Error creating folder:', error)
        this.error = error.message
        return { success: false, error: error.message }
      }
    },

    setCurrentNote(note) {
      this.currentNote = note
    },

    setSearchQuery(query) {
      this.searchQuery = query
    },

    clearError() {
      this.error = null
    }
  }
})
