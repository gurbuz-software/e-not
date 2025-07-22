<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
    <!-- Header Section -->
    <div class="mb-8">
      <div class="flex items-center justify-between">
        <div>
          <h1 :class="[
            'text-3xl font-bold text-gray-900 dark:text-white',
            adminStore.isAdmin ? 'font-mono tracking-wider' : 'font-serif'
          ]">
            {{ adminStore.isAdmin ? 'Admin Dashboard' : $t('dashboard.title') }}
          </h1>
          <p :class="[
            'mt-1 text-gray-600 dark:text-gray-400',
            adminStore.isAdmin ? 'font-mono text-sm tracking-wide' : 'font-sans'
          ]">
            {{ adminStore.isAdmin ? 'Sistem yönetim paneli' : $t('dashboard.subtitle') }}
          </p>
        </div>
        
        <!-- Actions -->
        <div class="flex items-center space-x-4">
          <!-- Search -->
          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
              </svg>
            </div>
            <input
              v-model="searchQuery"
              @input="notesStore.setSearchQuery(searchQuery)"
              type="text"
              :placeholder="$t('dashboard.search')"
              class="block w-full pl-10 pr-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md leading-5 bg-white dark:bg-gray-700 placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-white focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
            >
          </div>
          
          <!-- New Note Button -->
          <button
            @click="createNewNote"
            :disabled="notesStore.loading"
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <div v-if="notesStore.loading" class="animate-spin rounded-full h-4 w-4 border-b-2 border-white -ml-1 mr-2"></div>
            <svg v-else class="-ml-1 mr-2 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
            </svg>
            {{ notesStore.loading ? $t('loading.text') : $t('dashboard.newNote') }}
          </button>
        </div>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8" :class="adminStore.isAdmin ? 'font-mono' : 'font-sans'">
      <div class="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg border border-gray-200 dark:border-gray-700">
        <div class="p-5">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-8 h-8 bg-blue-500 rounded-md flex items-center justify-center">
                <svg class="h-5 w-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                </svg>
              </div>
            </div>
            <div class="ml-5 w-0 flex-1">
              <dl>
                <dt :class="[
                  'text-sm font-medium text-gray-500 dark:text-gray-400 truncate',
                  adminStore.isAdmin ? 'tracking-wide' : ''
                ]">
                  {{ $t('dashboard.totalNotes') }}
                </dt>
                <dd :class="[
                  'text-lg font-medium text-gray-900 dark:text-white',
                  adminStore.isAdmin ? 'tracking-wider font-bold' : ''
                ]">
                  {{ notesStore.notes.length }}
                </dd>
              </dl>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg border border-gray-200 dark:border-gray-700">
        <div class="p-5">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-8 h-8 bg-yellow-500 rounded-md flex items-center justify-center">
                <svg class="h-5 w-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                </svg>
              </div>
            </div>
            <div class="ml-5 w-0 flex-1">
              <dl>
                <dt :class="[
                  'text-sm font-medium text-gray-500 dark:text-gray-400 truncate',
                  adminStore.isAdmin ? 'tracking-wide' : ''
                ]">
                  {{ $t('dashboard.favoriteNotes') }}
                </dt>
                <dd :class="[
                  'text-lg font-medium text-gray-900 dark:text-white',
                  adminStore.isAdmin ? 'tracking-wider font-bold' : ''
                ]">
                  {{ notesStore.favoriteNotes.length }}
                </dd>
              </dl>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg border border-gray-200 dark:border-gray-700">
        <div class="p-5">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                <svg class="h-5 w-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"/>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3a2 2 0 012-2h4a2 2 0 012 2v4"/>
                </svg>
              </div>
            </div>
            <div class="ml-5 w-0 flex-1">
              <dl>
                <dt :class="[
                  'text-sm font-medium text-gray-500 dark:text-gray-400 truncate',
                  adminStore.isAdmin ? 'tracking-wide' : ''
                ]">
                  {{ $t('dashboard.folders') }}
                </dt>
                <dd :class="[
                  'text-lg font-medium text-gray-900 dark:text-white',
                  adminStore.isAdmin ? 'tracking-wider font-bold' : ''
                ]">
                  {{ notesStore.folders.length }}
                </dd>
              </dl>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg border border-gray-200 dark:border-gray-700">
        <div class="p-5">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-8 h-8 bg-purple-500 rounded-md flex items-center justify-center">
                <svg class="h-5 w-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
              </div>
            </div>
            <div class="ml-5 w-0 flex-1">
              <dl>
                <dt :class="[
                  'text-sm font-medium text-gray-500 dark:text-gray-400 truncate',
                  adminStore.isAdmin ? 'tracking-wide' : ''
                ]">
                  {{ $t('dashboard.recentNotes') }}
                </dt>
                <dd :class="[
                  'text-lg font-medium text-gray-900 dark:text-white',
                  adminStore.isAdmin ? 'tracking-wider font-bold' : ''
                ]">
                  {{ notesStore.recentNotes.length }}
                </dd>
              </dl>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Notes Grid -->
    <div class="mb-6" :class="adminStore.isAdmin ? 'font-mono' : 'font-sans'">
      <div class="flex items-center justify-between mb-4">
        <h2 :class="[
          'text-xl font-semibold text-gray-900 dark:text-white',
          adminStore.isAdmin ? 'tracking-wide' : ''
        ]">
          {{ searchQuery ? $t('dashboard.searchResults') : $t('dashboard.allNotes') }}
        </h2>
        <div class="flex items-center space-x-2">
          <!-- View Toggle -->
          <div class="flex bg-gray-100 dark:bg-gray-700 rounded-md p-1">
            <button
              @click="viewMode = 'grid'"
              :class="[
                'px-3 py-1 rounded text-sm font-medium transition-colors',
                viewMode === 'grid'
                  ? 'bg-white dark:bg-gray-600 text-gray-900 dark:text-white shadow'
                  : 'text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300'
              ]"
            >
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"/>
              </svg>
            </button>
            <button
              @click="viewMode = 'list'"
              :class="[
                'px-3 py-1 rounded text-sm font-medium transition-colors',
                viewMode === 'list'
                  ? 'bg-white dark:bg-gray-600 text-gray-900 dark:text-white shadow'
                  : 'text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300'
              ]"
            >
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16"/>
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="notesStore.loading" class="text-center py-12">
        <div class="inline-flex items-center">
          <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mr-3"></div>
          <span :class="[
            'text-gray-600 dark:text-gray-400',
            adminStore.isAdmin ? 'tracking-wide' : ''
          ]">{{ $t('loading.text') }}</span>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="displayedNotes.length === 0" class="text-center py-12">
        <div class="mx-auto h-12 w-12 text-gray-400 mb-4">
          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
          </svg>
        </div>
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
          {{ searchQuery ? $t('dashboard.noSearchResults') : $t('notes.empty') }}
        </h3>
        <p class="text-gray-600 dark:text-gray-400 mb-6">
          {{ searchQuery ? $t('dashboard.tryDifferentSearch') : $t('dashboard.createFirstNote') }}
        </p>
        <button
          v-if="!searchQuery"
          @click="createNewNote"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-primary-700 dark:text-primary-300 bg-primary-100 dark:bg-primary-900 hover:bg-primary-200 dark:hover:bg-primary-800 transition-colors"
        >
          <svg class="-ml-1 mr-2 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
          </svg>
          {{ $t('dashboard.createNote') }}
        </button>
      </div>

      <!-- Notes Grid/List -->
      <div v-else>
        <div
          :class="[
            viewMode === 'grid'
              ? 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6'
              : 'space-y-4'
          ]"
        >
          <NoteCard
            v-for="note in displayedNotes"
            :key="note.id"
            :note="note"
            :class="{
              'w-full': viewMode === 'list'
            }"
            @edit="editNote"
            @delete="confirmDeleteNote"
          />
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div
      v-if="noteToDelete"
      class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
      @click="cancelDelete"
    >
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white dark:bg-gray-800">
        <div class="mt-3 text-center">
          <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100 dark:bg-red-900">
            <svg class="h-6 w-6 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.996-.833-2.732 0L3.732 16c-.77.833.192 2.5 1.732 2.5z"/>
            </svg>
          </div>
          <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white">{{ $t('dashboard.deleteNote') }}</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500 dark:text-gray-400">
              {{ $t('dashboard.deleteConfirmation') }}
            </p>
          </div>
          <div class="items-center px-4 py-3">
            <div class="flex space-x-3">
              <button
                @click="cancelDelete"
                class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 text-base font-medium rounded-md w-24 hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
              >
                {{ $t('common.cancel') }}
              </button>
              <button
                @click="deleteNote"
                :disabled="deletingNote"
                class="px-4 py-2 bg-red-600 text-white text-base font-medium rounded-md w-24 hover:bg-red-700 disabled:opacity-50 transition-colors"
              >
                <span v-if="!deletingNote">{{ $t('common.delete') }}</span>
                <div v-else class="flex items-center justify-center">
                  <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Edit Note Modal -->
    <div
      v-if="noteToEdit"
      class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
      @click="cancelEdit"
    >
      <div 
        class="relative top-10 mx-auto p-6 border max-w-2xl shadow-lg rounded-md bg-white dark:bg-gray-800"
        @click.stop
      >
        <div class="mb-4">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              {{ $t('notes.edit') }}
            </h3>
            <button
              @click="cancelEdit"
              class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
            >
              <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
          
          <!-- Title Input -->
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('notes.title') }}
            </label>
            <input
              v-model="noteToEdit.title"
              type="text"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              :placeholder="$t('notes.titlePlaceholder')"
            >
          </div>
          
          <!-- Content Textarea -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('notes.content') }}
            </label>
            <textarea
              v-model="noteToEdit.content_text"
              rows="10"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 resize-none"
              :placeholder="$t('notes.contentPlaceholder')"
            ></textarea>
          </div>
          
          <!-- Action Buttons -->
          <div class="flex justify-end space-x-3">
            <button
              @click="cancelEdit"
              class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-600 border border-gray-300 dark:border-gray-600 rounded-md hover:bg-gray-200 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500 transition-colors"
            >
              {{ $t('common.cancel') }}
            </button>
            <button
              @click="saveNote"
              :disabled="editingNote"
              class="px-4 py-2 text-sm font-medium text-white bg-primary-600 border border-transparent rounded-md hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <span v-if="!editingNote">{{ $t('common.save') }}</span>
              <div v-else class="flex items-center">
                <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                {{ $t('common.saving') }}
              </div>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useAdminStore } from '../stores/admin'
import { useNotesStore } from '../stores/notes'
import NoteCard from '../components/NoteCard.vue'
import { supabase } from '../lib/supabase'

const authStore = useAuthStore()
const adminStore = useAdminStore()
const notesStore = useNotesStore()

const searchQuery = ref('')
const viewMode = ref('grid') // 'grid' or 'list'
const noteToDelete = ref(null)
const deletingNote = ref(false)
const noteToEdit = ref(null)
const editingNote = ref(false)

const displayedNotes = computed(() => {
  return notesStore.filteredNotes
})

const createNewNote = async () => {
  try {
    // Create an empty JSON content structure for new notes
    const contentJson = {
      type: 'doc',
      content: []
    }
    
    const result = await notesStore.createNote({
      title: 'Untitled Note',
      content: contentJson,
      content_text: ''
    })
    
    if (result.success) {
      // Automatically open the note for editing
      editNote(result.note)
    } else {
      console.error('Failed to create note:', result.error)
      // You could show a toast notification here
    }
  } catch (error) {
    console.error('Error in createNewNote:', error)
  }
}

const editNote = (note) => {
  // Create a reactive copy of the note to edit and extract clean text
  const cleanText = extractTextFromContent(note)
  noteToEdit.value = { 
    ...note, 
    content_text: cleanText 
  }
  notesStore.setCurrentNote(note)
}

// Function to extract clean text from note content JSON
const extractTextFromContent = (note) => {
  if (note.content && typeof note.content === 'object') {
    try {
      const content = typeof note.content === 'string' ? JSON.parse(note.content) : note.content
      
      if (content.content && Array.isArray(content.content)) {
        let textParts = []
        
        const extractTextRecursive = (items) => {
          for (const item of items) {
            if (item.type === 'text' && item.text) {
              textParts.push(item.text)
            } else if (item.content && Array.isArray(item.content)) {
              extractTextRecursive(item.content)
            }
          }
        }
        
        extractTextRecursive(content.content)
        return textParts.join(' ').trim()
      }
    } catch (error) {
      console.error('Error parsing content JSON:', error)
    }
  }
  
  // Fallback: if content_text doesn't contain JSON structure, use it directly
  if (note.content_text && !note.content_text.includes('type doc content')) {
    return note.content_text.trim()
  }
  
  return ''
}

const cancelEdit = () => {
  noteToEdit.value = null
  editingNote.value = false
}

const saveNote = async () => {
  if (!noteToEdit.value) return
  
  editingNote.value = true
  
  try {
    // Create a simple JSON content structure for the content field
    const contentJson = {
      type: 'doc',
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: noteToEdit.value.content_text || ''
            }
          ]
        }
      ]
    }
    
    const updateData = {
      title: noteToEdit.value.title,
      content: contentJson,
      content_text: noteToEdit.value.content_text
    }
    
    const result = await notesStore.updateNote(noteToEdit.value.id, updateData)
    
    if (result.success) {
      noteToEdit.value = null
    } else {
      console.error('Failed to update note:', result.error)
    }
  } catch (error) {
    console.error('Error updating note:', error)
  } finally {
    editingNote.value = false
  }
}

const confirmDeleteNote = (note) => {
  noteToDelete.value = note
}

const cancelDelete = () => {
  noteToDelete.value = null
  deletingNote.value = false
}

const deleteNote = async () => {
  if (!noteToDelete.value) return
  
  deletingNote.value = true
  
  const result = await notesStore.deleteNote(noteToDelete.value.id)
  
  if (result.success) {
    noteToDelete.value = null
  }
  
  deletingNote.value = false
}

onMounted(async () => {
  // Fetch notes and folders on component mount
  await Promise.all([
    notesStore.fetchNotes(),
    notesStore.fetchFolders()
  ])
})
</script>
