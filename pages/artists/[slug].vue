<script setup lang="ts">
definePageMeta({ layout: 'default' })
const route = useRoute()
const supabase = useSupabaseClient()

type Artist = {
  id: number
  slug: string
  fullName: string
  description: string | null
  birthYear: number | null
  country: string | null
  imageUrl: string | null
}

type Artwork = {
  id: number
  title: string
  imageUrl: string | null
  exhibitionId: number
}

type Exhibition = {
  id: number
  title: string
  slug: string
}

const loading = ref(true)
const artist = ref<Artist | null>(null)
const artworks = ref<Artwork[]>([])
const exMap = ref<Record<number, Exhibition>>({})

const surname = computed(() => {
  if (!artist.value?.fullName) return ''
  const parts = artist.value.fullName.trim().split(/\s+/)
  return parts.length ? parts[parts.length - 1] : artist.value.fullName
})

const fetchData = async () => {
  loading.value = true
  const slug = String(route.params.slug)

  // 1) Художник
  const { data: a } = await supabase
    .from('artists')
    .select('id,slug,"fullName",description,"birthYear",country,"imageUrl"')
    .eq('slug', slug)
    .maybeSingle()

  if (!a) { loading.value = false; return }
  artist.value = a as Artist

  // 2) Його роботи, що виставлялися в галереї
  const { data: aw } = await supabase
    .from('artworks')
    .select('id,title,imageUrl,"exhibitionId"')
    .eq('artistId', a.id)
    .order('exhibitionId', { ascending: false })

  artworks.value = (aw || []) as Artwork[]

  // 3) Підтягнути назви/slug виставок для лінків
  const exIds = [...new Set(artworks.value.map(x => x.exhibitionId).filter(Boolean))]
  if (exIds.length) {
    const { data: exs } = await supabase
      .from('exhibitions')
      .select('id,title,slug')
      .in('id', exIds)
    const map: Record<number, Exhibition> = {}
    ;(exs || []).forEach((e: any) => { map[e.id] = e as Exhibition })
    exMap.value = map
  } else {
    exMap.value = {}
  }

  loading.value = false
}

onMounted(fetchData)

const goExhibition = (slug: string) => navigateTo('/exhibitions/' + slug)
</script>

<template>
  <div class="container page serif">
    <v-skeleton-loader v-if="loading" type="article, image"></v-skeleton-loader>

    <template v-else>
      <v-alert v-if="!artist" type="error" variant="tonal" class="mb-4">
        Художника не знайдено.
      </v-alert>

      <div v-if="artist" class="top">
        <!-- Ліва колонка -->
        <div class="left">
          <h1 class="surname">{{ surname }}</h1>

          <div class="field">
            <div class="label">Про художника</div>
            <div class="value" v-if="artist.description" v-html="artist.description.replace(/\n/g,'<br/>')"></div>
            <div class="muted" v-else>Опис відсутній.</div>
          </div>

          <div class="cols">
            <div class="field">
              <div class="label">Рік народження</div>
              <div class="value">{{ artist.birthYear ?? '—' }}</div>
            </div>
            <div class="field">
              <div class="label">Країна</div>
              <div class="value">{{ artist.country || '—' }}</div>
            </div>
          </div>
        </div>

        <!-- Права колонка — велике фото (≈50% ширини екрана) -->
        <div class="right img-frame">
          <v-img
            v-if="artist.imageUrl"
            :src="artist.imageUrl"
            :alt="artist.fullName"
            height="520"
            cover
          />
          <div v-else class="ph">Фото відсутнє</div>
        </div>
      </div>

      <!-- Перелік робіт -->
      <div class="works">
        <h2 class="h">Роботи в експозиціях галереї</h2>

        <div v-if="!artworks.length" class="muted">Наразі немає робіт для показу.</div>

        <div v-else class="grid">
          <div v-for="w in artworks" :key="w.id" class="cell">
            <div class="img-frame">
              <v-img v-if="w.imageUrl" :src="w.imageUrl" :alt="w.title" height="200" contain />
              <div v-else class="ph">—</div>
            </div>
            <div class="meta">
              <div class="title">{{ w.title }}</div>
              <div class="ex muted" v-if="exMap[w.exhibitionId]">
                з експозиції:
                <a class="alink" @click.prevent="goExhibition(exMap[w.exhibitionId].slug)">
                  {{ exMap[w.exhibitionId].title }}
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.serif{ font-family: "Cormorant Garamond", serif; }
.page{ padding-top:18px; padding-bottom:28px; }

.top{
  display:grid;
  grid-template-columns: 1fr 1fr; /* права колонка ~50% */
  gap: 24px;
  align-items: start;
  margin-bottom: 24px;
}

.surname{
  font-size: clamp(32px, 4vw, 56px);
  line-height: 1.05;
  margin-bottom: 12px;
}

.field{ margin-bottom: 14px; }
.label{ font-size: 14px; opacity:.75; margin-bottom: 4px; }
.value{ font-size: 18px; line-height: 1.6; }

.cols{
  display:grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-top: 8px;
}

.right{ min-height: 520px; }
.ph{
  height: 520px;
  display:flex; align-items:center; justify-content:center;
  color: rgba(0,0,0,.45);
}

.works{ margin-top: 8px; }
.h{ font-size: 24px; margin-bottom: 12px; }

.grid{
  display:grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
.cell{ display:grid; gap: 6px; }
.title{ font-size: 18px; }
.alink{ color: inherit; text-decoration: underline; cursor: pointer; }

@media (max-width: 1100px){
  .top{ grid-template-columns: 1fr; }
  .right{ order: -1; } /* на планшетах фото зверху */
}
@media (max-width: 900px){
  .grid{ grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 600px){
  .grid{ grid-template-columns: 1fr; }
}
</style>
