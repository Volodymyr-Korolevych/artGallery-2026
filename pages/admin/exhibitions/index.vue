<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

type Exhibition = { id:number; title:string; painterId:number|null; coverUrl?:string|null; cardUrl?:string|null; startDate?:string|null; endDate?:string|null; isPublished?:boolean; status?:string }

const items = ref<Exhibition[]>([])
const artistsById = ref<Record<number, string>>({})
const fmtUA = (v:string|null|undefined) => v ? new Date(v).toLocaleDateString('uk-UA') : '—'

const fetchAll = async () => {
  const { data: exhs } = await supabase.from('exhibitions').select('*').order('createdAt',{ascending:false})
  items.value = exhs || []
  const { data: artists } = await supabase.from('artists').select('id,"fullName"')
  artistsById.value = {}
  for (const a of (artists||[])) artistsById.value[a.id] = a.fullName
}
onMounted(fetchAll)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="font-serif text-2xl font-semibold text-neutral-900">Експозиції</h1>
      <NuxtLink to="/admin/exhibitions/new" class="btn-primary text-xs">Додати виставку</NuxtLink>
    </div>

    <div class="bg-white border border-neutral-100 overflow-hidden">
      <div
        v-for="e in items" :key="e.id"
        class="flex items-center gap-4 px-5 py-4 border-b border-neutral-50 last:border-0 cursor-pointer hover:bg-neutral-50 transition-colors"
        @click="navigateTo('/admin/exhibitions/'+e.id)"
      >
        <div class="w-20 h-14 shrink-0 bg-neutral-100 overflow-hidden">
          <img v-if="e.cardUrl" :src="e.cardUrl" class="w-full h-full object-cover" />
          <div v-else class="w-full h-full flex items-center justify-center text-neutral-300 text-xs">—</div>
        </div>
        <div class="flex-1 min-w-0">
          <div class="font-medium text-neutral-900 truncate">{{ e.title || 'Без назви' }}</div>
          <div class="text-xs text-neutral-400 mt-0.5">
            {{ artistsById[e.painterId||(-1 as any)] || '—' }} ·
            {{ fmtUA(e.startDate) }} — {{ fmtUA(e.endDate) }}
          </div>
        </div>
        <div class="shrink-0">
          <span v-if="e.isPublished" class="text-xs text-emerald-600 bg-emerald-50 px-2 py-1">Опубліковано</span>
          <span v-else class="text-xs text-neutral-400 bg-neutral-100 px-2 py-1">Чернетка</span>
        </div>
      </div>
      <div v-if="!items.length" class="px-5 py-10 text-sm text-neutral-400 text-center italic">Немає виставок</div>
    </div>
  </div>
</template>
