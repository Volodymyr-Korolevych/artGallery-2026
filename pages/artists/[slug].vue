<script setup lang="ts">
definePageMeta({ layout: 'default' })
const route = useRoute()
const supabase = useSupabaseClient()

type Artist  = { id:number; slug:string; fullName:string; description:string|null; birthYear:number|null; country:string|null; imageUrl:string|null }
type Artwork  = { id:number; title:string; imageUrl:string|null; exhibitionId:number; year?:number|null; description?:string|null }
type Exhibition = { id:number; title:string; slug:string }

const loading   = ref(true)
const artist    = ref<Artist|null>(null)
const artworks  = ref<Artwork[]>([])
const exMap     = ref<Record<number, Exhibition>>({})

const fetchData = async () => {
  loading.value = true
  const slug = String(route.params.slug)
  const { data: a } = await supabase.from('artists').select('id,slug,"fullName",description,"birthYear",country,"imageUrl"').eq('slug', slug).maybeSingle()
  if (!a) { loading.value = false; return }
  artist.value = a as Artist
  const { data: aw } = await supabase.from('artworks').select('id,title,year,imageUrl,description,"exhibitionId"').eq('artistId', a.id).order('exhibitionId',{ascending:false})
  artworks.value = (aw || []) as Artwork[]
  const exIds = [...new Set(artworks.value.map(x => x.exhibitionId).filter(Boolean))]
  if (exIds.length) {
    const { data: exs } = await supabase.from('exhibitions').select('id,title,slug').in('id', exIds)
    const map: Record<number, Exhibition> = {}
    ;(exs||[]).forEach((e:any) => { map[e.id] = e as Exhibition })
    exMap.value = map
  }
  loading.value = false
}
onMounted(fetchData)
</script>

<template>
  <div>
    <!-- Loading -->
    <div v-if="loading" class="animate-pulse space-y-4">
      <div class="h-8 bg-neutral-200 rounded w-1/3"></div>
      <div class="grid grid-cols-2 gap-8">
        <div class="space-y-3">
          <div class="h-4 bg-neutral-100 rounded w-full"></div>
          <div class="h-4 bg-neutral-100 rounded w-4/5"></div>
        </div>
        <div class="h-96 bg-neutral-100 rounded"></div>
      </div>
    </div>

    <template v-else>
      <div v-if="!artist" class="alert-error">Художника не знайдено.</div>

      <div v-if="artist">
        <!-- Top section -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-20 items-start mb-16">
          <!-- Left -->
          <div class="order-2 lg:order-1">
            <div class="divider"></div>
            <h1 class="font-serif text-5xl lg:text-6xl font-semibold leading-tight text-neutral-900 mb-8">
              {{ artist.fullName }}
            </h1>

            <div class="space-y-6">
              <div v-if="artist.description">
                <div class="text-xs tracking-widest uppercase text-neutral-400 mb-2">Про художника</div>
                <div class="text-base text-neutral-600 leading-relaxed" v-html="artist.description.replace(/\n/g,'<br/>')"></div>
              </div>

              <div class="grid grid-cols-2 gap-6 pt-2">
                <div v-if="artist.birthYear">
                  <div class="text-xs tracking-widest uppercase text-neutral-400 mb-1">Рік народження</div>
                  <div class="font-serif text-lg text-neutral-900">{{ artist.birthYear }}</div>
                </div>
                <div v-if="artist.country">
                  <div class="text-xs tracking-widest uppercase text-neutral-400 mb-1">Країна</div>
                  <div class="font-serif text-lg text-neutral-900">{{ artist.country }}</div>
                </div>
              </div>
            </div>
          </div>

          <!-- Right: portrait -->
          <div class="order-1 lg:order-2 img-frame overflow-hidden">
            <img
              v-if="artist.imageUrl"
              :src="artist.imageUrl"
              :alt="artist.fullName"
              class="w-full max-h-[560px] object-cover"
            />
            <div v-else class="h-[460px] flex items-center justify-center text-neutral-300">
              <span class="font-serif text-7xl">{{ artist.fullName[0] }}</span>
            </div>
          </div>
        </div>

        <!-- Artworks -->
        <div>
          <h2 class="font-serif text-3xl font-semibold text-neutral-900 mb-8">Роботи в експозиціях галереї</h2>

          <div v-if="!artworks.length" class="text-sm text-neutral-400 italic">Наразі немає робіт для показу.</div>

          <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <div v-for="w in artworks" :key="w.id" class="art-card overflow-hidden">
              <div class="img-frame aspect-[4/3] overflow-hidden">
                <img
                  v-if="w.imageUrl"
                  :src="w.imageUrl"
                  :alt="w.title"
                  class="w-full h-full object-contain bg-neutral-50"
                />
                <div v-else class="w-full h-full flex items-center justify-center text-neutral-300 text-sm">—</div>
              </div>
              <div class="p-4 space-y-1">
                <div class="font-serif text-base font-semibold text-neutral-900">{{ w.title }}</div>
                <div v-if="w.year" class="text-xs text-neutral-400">{{ w.year }}</div>
                <div v-if="w.description" class="text-sm text-neutral-500 leading-relaxed">{{ w.description }}</div>
                <div v-if="exMap[w.exhibitionId]" class="text-xs text-neutral-400 pt-1">
                  з експозиції:
                  <NuxtLink :to="'/exhibitions/'+exMap[w.exhibitionId].slug" class="artist-link ml-1">
                    {{ exMap[w.exhibitionId].title }}
                  </NuxtLink>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
