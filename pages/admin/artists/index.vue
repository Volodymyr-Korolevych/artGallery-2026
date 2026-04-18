<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const items = ref<any[]>([])
const loading = ref(true)
const errorMsg = ref<string|null>(null)

const fetchArtists = async () => {
  loading.value = true
  const { data, error } = await supabase.from('artists').select('id,"fullName",country,birthYear,imageUrl').order('fullName')
  if (error) errorMsg.value = error.message
  items.value = data || []
  loading.value = false
}
onMounted(fetchArtists)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="font-serif text-2xl font-semibold text-neutral-900">Художники</h1>
      <NuxtLink to="/admin/artists/new" class="btn-primary text-xs">Додати</NuxtLink>
    </div>

    <div v-if="errorMsg" class="alert-error mb-4">{{ errorMsg }}</div>

    <div class="bg-white border border-neutral-100 overflow-hidden">
      <div
        v-for="a in items" :key="a.id"
        class="flex items-center gap-4 px-5 py-4 border-b border-neutral-50 last:border-0 cursor-pointer hover:bg-neutral-50 transition-colors"
        @click="navigateTo('/admin/artists/'+a.id)"
      >
        <div class="w-14 h-14 shrink-0 overflow-hidden bg-neutral-100">
          <img v-if="a.imageUrl" :src="a.imageUrl" class="w-full h-full object-cover" />
          <div v-else class="w-full h-full flex items-center justify-center font-serif text-xl text-neutral-300">
            {{ a.fullName?.[0] }}
          </div>
        </div>
        <div class="flex-1 min-w-0">
          <div class="font-medium text-neutral-900">{{ a.fullName }}</div>
          <div class="text-xs text-neutral-400 mt-0.5">
            {{ a.country || '—' }}
            <span v-if="a.birthYear"> · {{ a.birthYear }}</span>
          </div>
        </div>
        <svg class="w-4 h-4 text-neutral-300" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5l7 7-7 7"/>
        </svg>
      </div>
      <div v-if="!loading && !items.length" class="px-5 py-10 text-sm text-neutral-400 text-center italic">Немає художників</div>
      <div v-if="loading" class="px-5 py-10 text-sm text-neutral-400 text-center">Завантаження...</div>
    </div>
  </div>
</template>
