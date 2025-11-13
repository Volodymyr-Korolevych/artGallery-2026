<script setup lang="ts">
definePageMeta({ layout: 'default' })
const supabase = useSupabaseClient()
const route = useRoute()
const router = useRouter()

type Exhibition = {
  id: number
  slug: string
  title: string
  short: string|null
  status: 'past'|'current'|'upcoming'|null
  coverUrl: string|null
  painterId: number|null
  isPublished: boolean|null
  startDate: string|null
}
type Artist = { id:number; fullName:string; slug:string }

const loading = ref(true)
const items = ref<Exhibition[]>([])
const artistMap = ref<Record<number, Artist>>({})

const pageSize = 4
const page = ref<number>(Number(route.query.page || 1) || 1)
watch(() => route.query.page, (q) => {
  const p = Number(q || 1) || 1
  page.value = p < 1 ? 1 : p
})

const fetchAll = async () => {
  loading.value = true
  const { data: ex } = await supabase
    .from('exhibitions')
    .select('id,slug,title,short,status,coverUrl,"painterId","isPublished","startDate"')
    .eq('isPublished', true)
    .eq('status','upcoming')
    .order('startDate', { ascending: true })

  items.value = (ex || []) as Exhibition[]

  const ids = [...new Set(items.value.map(x => x.painterId).filter(Boolean))] as number[]
  if (ids.length) {
    const { data: arts } = await supabase.from('artists').select('id,"fullName",slug').in('id', ids)
    const map: Record<number, Artist> = {}
    ;(arts||[]).forEach((a:any)=>{ map[a.id] = a as Artist })
    artistMap.value = map
  } else {
    artistMap.value = {}
  }
  loading.value = false
}
onMounted(fetchAll)

const artistOf = (e: Exhibition) => e.painterId ? artistMap.value[e.painterId] || null : null

const pageCount = computed(() => Math.max(1, Math.ceil(items.value.length / pageSize)))
const paged = computed(() => {
  const start = (page.value - 1) * pageSize
  return items.value.slice(start, start + pageSize)
})

const goPage = (p:number) => {
  const safe = Math.min(Math.max(1, p), pageCount.value)
  router.replace({ query: { ...route.query, page: safe } })
}
</script>

<template>
  <div class="container page">
    <h1 class="title serif">Майбутні експозиції</h1>

    <v-skeleton-loader v-if="loading" type="article, image"></v-skeleton-loader>

    <div v-else>
      <div v-if="!items.length" class="muted">Наразі немає анонсованих експозицій.</div>

      <div class="list" v-else>
        <ExhibitionItemUpcoming
          v-for="e in paged"
          :key="e.id"
          :slug="e.slug"
          :title="e.title"
          :short="e.short"
          :coverUrl="e.coverUrl"
          :artist="artistOf(e)"
        />
      </div>

      <div class="pager" v-if="pageCount > 1">
        <v-btn variant="tonal" :disabled="page<=1" @click="goPage(page-1)">Попередня</v-btn>
        <span class="muted">Сторінка {{ page }} з {{ pageCount }}</span>
        <v-btn variant="tonal" :disabled="page>=pageCount" @click="goPage(page+1)">Наступна</v-btn>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page{ padding-top:18px; padding-bottom:28px; }
.title{ font-size: clamp(28px, 3vw, 40px); margin-bottom: 10px; }
.serif { font-family: "Cormorant Garamond", serif; }

.list{
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}

.pager{
  display:flex; align-items:center; justify-content:center; gap:12px;
  margin-top: 16px;
}
</style>
