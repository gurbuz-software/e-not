<template>
  <div class="group bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 hover:shadow-md transition-shadow duration-200 p-4">
    <div class="flex items-start justify-between mb-3">
      <div class="flex-1 min-w-0">
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white truncate mb-1">
          {{ note.title }}
        </h3>
        <p class="text-sm text-gray-500 dark:text-gray-400">
          {{ formatDate(note.updated_at) }}
        </p>
      </div>
      
      <!-- Actions -->
      <div class="flex items-center space-x-2 opacity-0 group-hover:opacity-100 transition-opacity">
        <button
          @click.stop="toggleFavorite"
          class="p-1.5 rounded-md text-gray-400 hover:text-yellow-500 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          :class="{ 'text-yellow-500': note.is_favorite }"
          :title="note.is_favorite ? $t('notes.removeFavorite') : $t('notes.addFavorite')"
        >
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
          </svg>
        </button>
        
        <button
          @click.stop="editNote"
          class="p-1.5 rounded-md text-gray-400 hover:text-blue-500 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          :title="$t('notes.edit')"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
          </svg>
        </button>
        
        <button
          @click.stop="deleteNote"
          class="p-1.5 rounded-md text-gray-400 hover:text-red-500 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          :title="$t('notes.delete')"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
          </svg>
        </button>
      </div>
    </div>

    <!-- Content Preview -->
    <div class="mb-3">
      <!-- Debug info - remove after fixing -->
      <div v-if="showDebug" class="bg-red-100 p-2 text-xs mb-2 rounded">
        <div><strong>content_text:</strong> {{ note.content_text }}</div>
        <div><strong>content:</strong> {{ JSON.stringify(note.content) }}</div>
      </div>
      
      <p class="text-gray-600 dark:text-gray-300 text-sm line-clamp-3 leading-relaxed">
        <span v-if="extractTextFromNote(note)" class="text-gray-900 dark:text-gray-100">{{ extractTextFromNote(note) }}</span>
        <span v-else class="text-gray-400 dark:text-gray-500 italic">{{ $t('notes.emptyNote') }}</span>
      </p>
    </div>

    <!-- Tags -->
    <div v-if="note.tags && note.tags.length > 0" class="flex flex-wrap gap-1 mb-3">
      <span
        v-for="tag in note.tags.slice(0, 3)"
        :key="tag"
        class="inline-flex px-2 py-1 text-xs font-medium bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded-md"
      >
        #{{ tag }}
      </span>
      <span
        v-if="note.tags.length > 3"
        class="inline-flex px-2 py-1 text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 rounded-md"
      >
        +{{ note.tags.length - 3 }}
      </span>
    </div>

    <!-- Footer -->
    <div class="flex items-center justify-between pt-2 border-t border-gray-100 dark:border-gray-700">
      <div class="flex items-center text-xs text-gray-500 dark:text-gray-400">
        <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
        </svg>
        {{ $t('notes.note') }}
      </div>
      
      <div v-if="note.is_favorite" class="text-yellow-500">
        <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
        </svg>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useNotesStore } from '../stores/notes'
import { useI18n } from 'vue-i18n'

const props = defineProps({
  note: {
    type: Object,
    required: true
  }
})

// Temporary debug mode - set to true to see note data
const showDebug = ref(false)

const emit = defineEmits(['edit', 'delete'])

const notesStore = useNotesStore()
const { t } = useI18n()

// Function to extract clean text from note content
const extractTextFromNote = (note) => {
  // First try to get text from the content JSON
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

const formatDate = (dateString) => {
  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now - date
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))

  if (diffDays === 0) {
    return t('dates.today')
  } else if (diffDays === 1) {
    return t('dates.yesterday')
  } else if (diffDays < 7) {
    return t('dates.daysAgo', { count: diffDays })
  } else {
    return date.toLocaleDateString()
  }
}

const toggleFavorite = async () => {
  await notesStore.toggleFavorite(props.note.id)
}

const editNote = () => {
  emit('edit', props.note)
}

const deleteNote = () => {
  emit('delete', props.note)
}
</script>

<style scoped>
.line-clamp-3 {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
