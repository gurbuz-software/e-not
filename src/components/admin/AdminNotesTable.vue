<template>
  <div class="bg-white dark:bg-gray-800 shadow rounded-lg border border-gray-200 dark:border-gray-700">
    <!-- Table Header -->
    <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
      <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white">
        {{ $t('admin.allNotes') }}
      </h3>
      <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
        {{ $t('admin.manageAllUserNotes') }}
      </p>
    </div>

    <!-- Empty State -->
    <div v-if="notes.length === 0" class="text-center py-12">
      <div class="mx-auto h-12 w-12 text-gray-400 mb-4">
        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
        </svg>
      </div>
      <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
        {{ $t('admin.noNotes') }}
      </h3>
      <p class="text-gray-600 dark:text-gray-400">
        {{ $t('admin.noNotesDescription') }}
      </p>
    </div>

    <!-- Table -->
    <div v-else class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-900">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              {{ $t('admin.noteTitle') }}
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              {{ $t('admin.author') }}
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              {{ $t('admin.folder') }}
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              {{ $t('admin.status') }}
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              {{ $t('admin.lastUpdated') }}
            </th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              {{ $t('admin.actions') }}
            </th>
          </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
          <tr v-for="note in notes" :key="note.note_id" class="hover:bg-gray-50 dark:hover:bg-gray-700">
            <!-- Title & Preview -->
            <td class="px-6 py-4">
              <div class="max-w-xs">
                <div class="text-sm font-medium text-gray-900 dark:text-white truncate">
                  {{ note.note_title }}
                </div>
                <div class="text-sm text-gray-500 dark:text-gray-400 truncate mt-1">
                  {{ extractTextPreview(note.note_content_text) }}
                </div>
              </div>
            </td>

            <!-- Author -->
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex items-center">
                <div class="flex-shrink-0 h-8 w-8">
                  <div class="h-8 w-8 rounded-full bg-gray-300 dark:bg-gray-600 flex items-center justify-center">
                    <span class="text-xs font-medium text-gray-700 dark:text-gray-300">
                      {{ getInitials(note.user_email) }}
                    </span>
                  </div>
                </div>
                <div class="ml-3">
                  <div class="text-sm font-medium text-gray-900 dark:text-white">
                    {{ note.user_first_name && note.user_last_name 
                        ? `${note.user_first_name} ${note.user_last_name}` 
                        : note.user_email }}
                  </div>
                  <div class="text-sm text-gray-500 dark:text-gray-400">
                    {{ note.user_email }}
                  </div>
                </div>
              </div>
            </td>

            <!-- Folder -->
            <td class="px-6 py-4 whitespace-nowrap">
              <span v-if="note.folder_name" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200">
                {{ note.folder_name }}
              </span>
              <span v-else class="text-sm text-gray-500 dark:text-gray-400">
                {{ $t('admin.noFolder') }}
              </span>
            </td>

            <!-- Status -->
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex space-x-1">
                <span v-if="note.note_is_favorite" class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200">
                  ⭐ {{ $t('admin.favorite') }}
                </span>
                <span v-if="note.note_is_archived" class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200">
                  📁 {{ $t('admin.archived') }}
                </span>
                <span v-if="!note.note_is_favorite && !note.note_is_archived" class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200">
                  ✓ {{ $t('admin.active') }}
                </span>
              </div>
            </td>

            <!-- Last Updated -->
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
              {{ formatDate(note.note_updated_at) }}
            </td>

            <!-- Actions -->
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <div class="flex justify-end space-x-2">
                <button
                  @click="$emit('edit', note)"
                  class="text-primary-600 hover:text-primary-900 dark:text-primary-400 dark:hover:text-primary-300"
                  :title="$t('admin.editNote')"
                >
                  <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                  </svg>
                </button>
                <button
                  @click="$emit('delete', note)"
                  class="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300"
                  :title="$t('admin.deleteNote')"
                >
                  <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                  </svg>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Table Footer with Stats -->
    <div v-if="notes.length > 0" class="px-6 py-3 bg-gray-50 dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700">
      <div class="flex items-center justify-between text-sm text-gray-500 dark:text-gray-400">
        <div>
          {{ $t('admin.totalNotes') }}: {{ notes.length }}
        </div>
        <div class="flex space-x-4">
          <span>{{ $t('admin.favoriteCount') }}: {{ favoriteCount }}</span>
          <span>{{ $t('admin.archivedCount') }}: {{ archivedCount }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const props = defineProps({
  notes: {
    type: Array,
    required: true
  }
})

defineEmits(['edit', 'delete'])

const { t } = useI18n()

const favoriteCount = computed(() => 
  props.notes.filter(note => note.note_is_favorite).length
)

const archivedCount = computed(() => 
  props.notes.filter(note => note.note_is_archived).length
)

const extractTextPreview = (text) => {
  if (!text) return t('admin.noContent')
  
  // Remove JSON artifacts and get clean text
  const cleanText = text.replace(/type doc content|type paragraph|type text/g, '').trim()
  return cleanText.substring(0, 60) + (cleanText.length > 60 ? '...' : '')
}

const getInitials = (email) => {
  if (!email) return '?'
  const name = email.split('@')[0]
  return name.substring(0, 2).toUpperCase()
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  
  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now - date
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
  const diffMinutes = Math.floor(diffMs / (1000 * 60))

  if (diffMinutes < 60) {
    return t('dates.minutesAgo', { count: diffMinutes })
  } else if (diffHours < 24) {
    return t('dates.hoursAgo', { count: diffHours })
  } else if (diffDays === 0) {
    return t('dates.today')
  } else if (diffDays === 1) {
    return t('dates.yesterday')
  } else if (diffDays < 7) {
    return t('dates.daysAgo', { count: diffDays })
  } else {
    return date.toLocaleDateString()
  }
}
</script>
