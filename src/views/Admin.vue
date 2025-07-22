<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
    <!-- Access Denied State -->
    <div v-if="!adminStore.isAdmin" class="text-center py-12">
      <div class="mx-auto h-12 w-12 text-red-400 mb-4">
        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.996-.833-2.732 0L3.732 16c-.77.833.192 2.5 1.732 2.5z"/>
        </svg>
      </div>
      <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
        {{ $t('admin.accessDenied') }}
      </h3>
      <p class="text-gray-600 dark:text-gray-400">
        {{ $t('admin.adminPrivilegesRequired') }}
      </p>
    </div>

    <!-- Admin Panel -->
    <div v-else>
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
          {{ $t('admin.title') }}
        </h1>
        <p class="mt-1 text-gray-600 dark:text-gray-400">
          {{ $t('admin.subtitle') }}
        </p>
      </div>

      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <!-- Total Notes -->
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
                  <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                    {{ $t('admin.totalNotes') }}
                  </dt>
                  <dd class="text-lg font-medium text-gray-900 dark:text-white">
                    {{ adminStore.totalNotesCount }}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <!-- Total Users -->
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg border border-gray-200 dark:border-gray-700">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                  <svg class="h-5 w-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a4 4 0 11-8 0 4 4 0 018 0z"/>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                    {{ $t('admin.totalUsers') }}
                  </dt>
                  <dd class="text-lg font-medium text-gray-900 dark:text-white">
                    {{ adminStore.totalUsersCount }}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <!-- Admin Users -->
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg border border-gray-200 dark:border-gray-700">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-purple-500 rounded-md flex items-center justify-center">
                  <svg class="h-5 w-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                    {{ $t('admin.adminUsers') }}
                  </dt>
                  <dd class="text-lg font-medium text-gray-900 dark:text-white">
                    {{ adminStore.adminUsers.length }}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <!-- Regular Users -->
        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg border border-gray-200 dark:border-gray-700">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-yellow-500 rounded-md flex items-center justify-center">
                  <svg class="h-5 w-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                  </svg>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                    {{ $t('admin.regularUsers') }}
                  </dt>
                  <dd class="text-lg font-medium text-gray-900 dark:text-white">
                    {{ adminStore.regularUsers.length }}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabs -->
      <div class="mb-6">
        <div class="border-b border-gray-200 dark:border-gray-700">
          <nav class="-mb-px flex space-x-8">
            <button
              @click="activeTab = 'notes'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'notes'
                  ? 'border-primary-500 text-primary-600 dark:text-primary-400'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-gray-400 dark:hover:text-gray-300'
              ]"
            >
              {{ $t('admin.allNotes') }} ({{ adminStore.totalNotesCount }})
            </button>
            <button
              @click="activeTab = 'users'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'users'
                  ? 'border-primary-500 text-primary-600 dark:text-primary-400'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-gray-400 dark:hover:text-gray-300'
              ]"
            >
              {{ $t('admin.allUsers') }} ({{ adminStore.totalUsersCount }})
            </button>
          </nav>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="adminStore.loading" class="text-center py-12">
        <div class="inline-flex items-center">
          <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mr-3"></div>
          <span class="text-gray-600 dark:text-gray-400">{{ $t('loading.text') }}</span>
        </div>
      </div>

      <!-- Notes Tab -->
      <div v-else-if="activeTab === 'notes'">
        <AdminNotesTable 
          :notes="adminStore.allNotes"
          @edit="editNote"
          @delete="deleteNote"
        />
      </div>

      <!-- Users Tab -->
      <div v-else-if="activeTab === 'users'">
        <AdminUsersTable 
          :users="adminStore.allUsers"
          @toggle-admin="toggleAdminStatus"
        />
      </div>
    </div>

    <!-- Edit Note Modal -->
    <AdminNoteEditModal
      v-if="noteToEdit"
      :note="noteToEdit"
      @save="saveNote"
      @close="noteToEdit = null"
    />

    <!-- Delete Confirmation Modal -->
    <AdminDeleteModal
      v-if="noteToDelete"
      :item="noteToDelete"
      type="note"
      @confirm="confirmDelete"
      @cancel="noteToDelete = null"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAdminStore } from '../stores/admin'
import { useI18n } from 'vue-i18n'
import AdminNotesTable from '../components/admin/AdminNotesTable.vue'
import AdminUsersTable from '../components/admin/AdminUsersTable.vue'
import AdminNoteEditModal from '../components/admin/AdminNoteEditModal.vue'
import AdminDeleteModal from '../components/admin/AdminDeleteModal.vue'

const adminStore = useAdminStore()
const { t } = useI18n()

const activeTab = ref('notes')
const noteToEdit = ref(null)
const noteToDelete = ref(null)

const editNote = (note) => {
  noteToEdit.value = note
}

const deleteNote = (note) => {
  noteToDelete.value = note
}

const saveNote = async (noteId, updates) => {
  const result = await adminStore.adminUpdateNote(noteId, updates)
  if (result.success) {
    noteToEdit.value = null
  }
}

const confirmDelete = async () => {
  if (noteToDelete.value) {
    const result = await adminStore.adminDeleteNote(noteToDelete.value.note_id)
    if (result.success) {
      noteToDelete.value = null
    }
  }
}

const toggleAdminStatus = async (user) => {
  if (user.is_admin) {
    await adminStore.removeAdminPrivileges(user.user_id)
  } else {
    await adminStore.makeUserAdmin(user.user_id)
  }
}

onMounted(async () => {
  await adminStore.initializeAdminData()
})
</script>
