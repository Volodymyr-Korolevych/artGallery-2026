<script setup lang="ts">
definePageMeta({ layout: 'default' })
const route = useRoute(); const supabase = useSupabaseClient()

type Exhibition = { id:number; slug:string; title:string; short:string|null; description:string|null; startDate:string|null; endDate:string|null; coverUrl:string|null; status:'past'|'current'|'upcoming'|null; painterId:number|null; isPublished:boolean|null }
type Artist  = { id:number; fullName:string; slug:string }
type Artwork = { id:number; title:string; year:number|null; description:string|null; imageUrl:string|null; slot:number }

const loading = ref(true); const ex = ref<Exhibition|null>(null); const artist = ref<Artist|null>(null); const artworks = ref<Artwork[]>([])

const statusLabel = (s: Exhibition['status']) => s==='past'?'Минула':s==='current'?'Поточна':s==='upcoming'?'Майбутня':''
const statusClass = (s: Exhibition['status']) => s==='current'?'current':s==='upcoming'?'upcoming':'past'
const fmtRange = (s:string|null, e:string|null) => {
  const toD=(v:string|null)=>(v?new Date(v):null)
  const sD=toD(s),eD=toD(e)
  const f=(d:Date)=>d.toLocaleDateString('uk-UA',{year:'numeric',month:'long',day:'numeric'})
  if(sD&&eD) return `${f(sD)} — ${f(eD)}`
  if(sD) return f(sD); if(eD) return f(eD); return ''
}

const fetchAll = async () => {
  loading.value = true
  const slug = String(route.params.slug)
  const { data: e, error } = await supabase.from('exhibitions').select('id,slug,title,short,description,coverUrl,status,"startDate","endDate","painterId","isPublished"').eq('slug',slug).maybeSingle()
  if (!error && e) {
    ex.value = e as Exhibition
    if (e.painterId) {
      const { data: a } = await supabase.from('artists').select('id,"fullName",slug').eq('id',e.painterId).maybeSingle()
      artist.value = (a as Artist)||null
    }
    if (e.status==='past'||e.status==='current') {
      const { data: aw } = await supabase.from('artworks').select('id,title,year,description,imageUrl,slot').eq('exhibitionId',e.id).order('slot',{ascending:true}).limit(6)
      artworks.value = (aw||[]) as Artwork[]
    } else { artworks.value = [] }
  } else { ex.value = null }
  loading.value = false
}
onMounted(fetchAll)
</script>

<template>
  <div>
    <div v-if="loading" class="animate-pulse space-y-6">
      <div class="h-[400px] bg-neutral-200 rounded"></div>
      <div class="h-6 bg-neutral-100 rounded w-1/2"></div>
      <div class="h-10 bg-neutral-200 rounded w-3/4"></div>
    </div>

    <template v-else>
      <div v-if="!ex" class="alert-error">Виставку не знайдено.</div>

      <div v-if="ex">
        <!-- Cover -->
        <div class="img-frame overflow-hidden mb-10" v-if="ex.coverUrl">
          <img :src="ex.coverUrl" :alt="ex.title" class="w-full max-h-[500px] object-contain bg-neutral-50" />
        </div>

        <!-- Meta -->
        <div class="max-w-2xl mb-10">
          <span v-if="ex.status" :class="['status-badge mb-4 inline-block', statusClass(ex.status)]">{{ statusLabel(ex.status) }}</span>
          <div class="divider mt-3"></div>
          <h1 class="font-serif text-5xl lg:text-6xl font-semibold leading-tight text-neutral-900 mt-4 mb-4">{{ ex.title }}</h1>

          <div v-if="artist" class="text-sm text-neutral-500 mb-2">
            Художник:
            <NuxtLink :to="'/artists/'+artist.slug" class="artist-link ml-1">{{ artist.fullName }}</NuxtLink>
          </div>
          <div v-if="ex.startDate||ex.endDate" class="text-sm text-neutral-400 mb-6">
            {{ fmtRange(ex.startDate, ex.endDate) }}
          </div>
          <div v-if="ex.description" class="text-base text-neutral-600 leading-relaxed" v-html="ex.description.replace(/\n/g,'<br/>')"></div>
        </div>

        <!-- Artworks -->
        <div v-if="ex.status==='past'||ex.status==='current'" class="mt-12">
          <h2 class="font-serif text-3xl font-semibold text-neutral-900 mb-8">Роботи з експозиції</h2>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            <div v-for="a in artworks" :key="a.id" class="art-card overflow-hidden">
              <div class="img-frame aspect-[4/3] overflow-hidden">
                <img v-if="a.imageUrl" :src="a.imageUrl" :alt="a.title" class="w-full h-full object-contain bg-neutral-50" />
                <div v-else class="w-full h-full flex items-center justify-center text-neutral-300">—</div>
              </div>
              <div class="p-4 space-y-1">
                <div class="font-serif text-base font-semibold text-neutral-900">{{ a.title }}</div>
                <div v-if="a.year" class="text-xs text-neutral-400">{{ a.year }}</div>
                <div v-if="a.description" class="text-sm text-neutral-500 leading-relaxed">{{ a.description }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
