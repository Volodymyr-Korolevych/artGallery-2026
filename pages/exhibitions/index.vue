<script setup lang="ts">
definePageMeta({ layout: 'default' })
const supabase = useSupabaseClient()

type Exhibition = { id:number; slug:string; title:string; status:'past'|'current'|'upcoming'|null; startDate:string|null; endDate:string|null; cardUrl:string|null; painterId:number|null; isPublished:boolean|null }
type Artist = { id:number; fullName:string; slug:string }

const loading = ref(true)
const items = ref<Exhibition[]>([])
const artistMap = ref<Record<number, Artist>>({})

const fetchAll = async () => {
  loading.value = true
  const { data: ex } = await supabase.from('exhibitions').select('id,slug,title,status,"startDate","endDate","cardUrl","painterId","isPublished"').eq('isPublished',true).order('startDate',{ascending:false})
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
</script>

<template>
  <div>
    <div class="divider"></div>
    <h1 class="font-serif text-5xl font-semibold text-neutral-900 mb-10">Виставки</h1>

    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div v-for="n in 4" :key="n" class="animate-pulse">
        <div class="bg-neutral-200 aspect-[4/3] rounded mb-3"></div>
        <div class="h-4 bg-neutral-100 rounded w-2/3 mb-2"></div>
        <div class="h-3 bg-neutral-100 rounded w-1/2"></div>
      </div>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <ExhibitionCard
        v-for="e in items" :key="e.id"
        :slug="e.slug" :title="e.title" :status="e.status"
        :startDate="e.startDate" :endDate="e.endDate"
        :cardUrl="e.cardUrl" :artist="artistOf(e)"
      />
      <div v-if="!items.length" class="col-span-2 text-sm text-neutral-400 italic">Немає виставок для показу.</div>
    </div>
  </div>
</template>
