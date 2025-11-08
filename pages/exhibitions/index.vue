<script setup lang="ts">
definePageMeta({ layout: 'default' })
const supabase = useSupabaseClient()

type Exhibition = {
  id: number
  slug: string
  title: string
  status: 'past'|'current'|'upcoming'|null
  startDate: string|null
  endDate: string|null
  cardUrl: string|null
  painterId: number|null
  isPublished: boolean|null
}
type Artist = { id:number; fullName:string; slug:string }

const loading = ref(true)
const items = ref<Exhibition[]>([])
const artistMap = ref<Record<number, Artist>>({})

const fetchAll = async () => {
  loading.value = true
  // 1) всі публіковані виставки, сортування за датою початку (нові спершу)
  const { data: ex } = await supabase
    .from('exhibitions')
    .select('id,slug,title,status,"startDate","endDate","cardUrl","painterId","isPublished"')
    .eq('isPublished', true)
    .order('startDate', { ascending: false })

  items.value = (ex || []) as Exhibition[]

  // 2) підтягнути художників одним запитом
  const ids = [...new Set(items.value.map(x => x.painterId).filter(Boolean))] as number[]
  if (ids.length) {
    const { data: arts } = await supabase
      .from('artists')
      .select('id,"fullName",slug')
      .in('id', ids)
    const map: Record<number, Artist> = {}
    ;(arts||[]).forEach((a: any) => { map[a.id] = a as Artist })
    artistMap.value = map
  } else {
    artistMap.value = {}
  }

  loading.value = false
}
onMounted(fetchAll)

const artistOf = (e: Exhibition) => e.painterId ? artistMap.value[e.painterId] || null : null
</script>

<template>
  <div class="container page">
    <h1 class="title serif">Виставки</h1>

    <v-skeleton-loader v-if="loading" type="article, image"></v-skeleton-loader>

    <div v-else class="grid">
      <ExhibitionCard
        v-for="e in items"
        :key="e.id"
        :slug="e.slug"
        :title="e.title"
        :status="e.status"
        :startDate="e.startDate"
        :endDate="e.endDate"
        :cardUrl="e.cardUrl"
        :artist="artistOf(e)"
      />
      <div v-if="!items.length" class="muted">Немає виставок для показу.</div>
    </div>
  </div>
</template>

<style scoped>
.page{ padding-top:18px; padding-bottom:28px; }
.title{ font-size: clamp(28px, 3vw, 40px); margin-bottom: 10px; }
.serif { font-family: "Cormorant Garamond", serif; }

.grid{
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}
@media (max-width: 900px){
  .grid{ grid-template-columns: 1fr; }
}
</style>
