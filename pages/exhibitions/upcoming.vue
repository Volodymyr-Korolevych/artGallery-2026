<script setup lang="ts">
definePageMeta({ layout: 'default' })
const supabase = useSupabaseClient()
const route = useRoute(); const router = useRouter()

type Exhibition = { id:number; slug:string; title:string; short:string|null; status:'past'|'current'|'upcoming'|null; coverUrl:string|null; painterId:number|null; isPublished:boolean|null; startDate:string|null }
type Artist = { id:number; fullName:string; slug:string }

const loading = ref(true); const items = ref<Exhibition[]>([]); const artistMap = ref<Record<number, Artist>>({})
const pageSize = 4
const page = ref<number>(Number(route.query.page || 1) || 1)
watch(() => route.query.page, (q) => { const p = Number(q||1)||1; page.value = p<1?1:p })

const fetchAll = async () => {
  loading.value = true
  const { data: ex } = await supabase.from('exhibitions').select('id,slug,title,short,status,coverUrl,"painterId","isPublished","startDate"').eq('isPublished',true).eq('status','upcoming').order('startDate',{ascending:true})
  items.value = (ex||[]) as Exhibition[]
  const ids = [...new Set(items.value.map(x => x.painterId).filter(Boolean))] as number[]
  if (ids.length) {
    const { data: arts } = await supabase.from('artists').select('id,"fullName",slug').in('id', ids)
    const map: Record<number,Artist> = {}
    ;(arts||[]).forEach((a:any)=>{ map[a.id]=a as Artist })
    artistMap.value = map
  }
  loading.value = false
}
onMounted(fetchAll)

const artistOf = (e: Exhibition) => e.painterId ? artistMap.value[e.painterId] || null : null
const pageCount = computed(() => Math.max(1, Math.ceil(items.value.length / pageSize)))
const paged = computed(() => { const start = (page.value-1)*pageSize; return items.value.slice(start, start+pageSize) })
const goPage = (p:number) => { const safe = Math.min(Math.max(1,p), pageCount.value); router.replace({ query: {...route.query, page: safe} }) }
</script>

<template>
  <div>
    <div class="divider"></div>
    <h1 class="font-serif text-5xl font-semibold text-neutral-900 mb-10">Майбутні експозиції</h1>

    <div v-if="loading" class="space-y-4">
      <div v-for="n in 3" :key="n" class="animate-pulse flex gap-6 bg-white border border-neutral-100 p-6">
        <div class="bg-neutral-200 w-60 h-40 shrink-0 rounded"></div>
        <div class="flex-1 space-y-3 py-2">
          <div class="h-4 bg-neutral-100 rounded w-3/4"></div>
          <div class="h-3 bg-neutral-100 rounded w-full"></div>
          <div class="h-3 bg-neutral-100 rounded w-4/5"></div>
        </div>
      </div>
    </div>

    <div v-else>
      <div v-if="!items.length" class="text-sm text-neutral-400 italic">Наразі немає анонсованих експозицій.</div>

      <div class="space-y-4" v-else>
        <ExhibitionItemUpcoming
          v-for="e in paged" :key="e.id"
          :slug="e.slug" :title="e.title" :short="e.short"
          :coverUrl="e.coverUrl" :artist="artistOf(e)"
        />
      </div>

      <div v-if="pageCount > 1" class="flex items-center justify-center gap-4 mt-10">
        <button class="pager-btn" :disabled="page<=1" @click="goPage(page-1)">← Попередня</button>
        <span class="text-xs text-neutral-400">{{ page }} / {{ pageCount }}</span>
        <button class="pager-btn" :disabled="page>=pageCount" @click="goPage(page+1)">Наступна →</button>
      </div>
    </div>
  </div>
</template>
