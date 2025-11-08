<script setup lang="ts">
definePageMeta({ layout: 'default' })

const route = useRoute()
const supabase = useSupabaseClient()

type Exhibition = {
  id: number
  slug: string
  title: string
  short: string | null
  description: string | null
  startDate: string | null
  endDate: string | null
  coverUrl: string | null
  status: 'past' | 'current' | 'upcoming' | null
  painterId: number | null
  isPublished: boolean | null
}
type Artist = { id: number; fullName: string; slug: string }
type Artwork = { id: number; title: string; imageUrl: string | null; slot: number }

const loading = ref(true)
const ex = ref<Exhibition | null>(null)
const artist = ref<Artist | null>(null)
const artworks = ref<Artwork[]>([])

const statusLabel = (s: Exhibition['status']) =>
  s === 'past' ? 'Минула' : s === 'current' ? 'Поточна' : s === 'upcoming' ? 'Майбутня' : ''

const fmtRange = (s: string | null, e: string | null) => {
  const toD = (v: string | null) => (v ? new Date(v) : null)
  const sD = toD(s), eD = toD(e)
  const f = (d: Date) => d.toLocaleDateString('uk-UA', { year: 'numeric', month: 'long', day: 'numeric' })
  if (sD && eD) return `${f(sD)} — ${f(eD)}`
  if (sD) return f(sD)
  if (eD) return f(eD)
  return ''
}

const fetchAll = async () => {
  loading.value = true
  const slug = String(route.params.slug)

  const { data: e, error } = await supabase
    .from('exhibitions')
    .select('id,slug,title,short,description,coverUrl,status,"startDate","endDate","painterId","isPublished"')
    .eq('slug', slug)
    .maybeSingle()

  if (!error && e) {
    ex.value = e as Exhibition

    if (e.painterId) {
      const { data: a } = await supabase
        .from('artists')
        .select('id,"fullName",slug')
        .eq('id', e.painterId).maybeSingle()
      artist.value = (a as Artist) || null
    }

    if (e.status === 'past' || e.status === 'current') {
      const { data: aw } = await supabase
        .from('artworks')
        .select('id,title,imageUrl,slot')
        .eq('exhibitionId', e.id)
        .order('slot', { ascending: true })
        .limit(6)
      artworks.value = (aw || []) as Artwork[]
    } else {
      artworks.value = []
    }
  } else {
    ex.value = null
  }

  loading.value = false
}

onMounted(fetchAll)

const goArtist = () => { if (artist.value?.slug) navigateTo('/artists/' + artist.value.slug) }
</script>

<template>
  <div class="container page serif">
    <v-skeleton-loader v-if="loading" type="image, article"></v-skeleton-loader>

    <template v-else>
      <v-alert v-if="!ex" type="error" variant="tonal" class="mb-4">
        Виставку не знайдено.
      </v-alert>

      <div v-if="ex">
        <!-- Cover -->
        <div class="img-frame mb-5" v-if="ex.coverUrl">
          <v-img :src="ex.coverUrl" :alt="ex.title" height="420" contain />
        </div>

        <!-- Meta -->
        <div class="meta">
          <div class="status" v-if="ex.status">{{ statusLabel(ex.status) }}</div>
          <h1 class="title">{{ ex.title }}</h1>

          <div class="artist" v-if="artist">
            Художник:
            <a class="artist-link" @click.prevent="goArtist">{{ artist.fullName }}</a>
          </div>

          <div class="dates" v-if="ex.startDate || ex.endDate">
            {{ fmtRange(ex.startDate, ex.endDate) }}
          </div>
        </div>

        <!-- Full description -->
        <div class="desc" v-if="ex.description" v-html="ex.description.replace(/\n/g,'<br/>')"></div>

        <!-- Artworks grid (past/current only) -->
        <div v-if="ex.status==='past' || ex.status==='current'" class="artworks">
          <h2 class="h">Роботи з експозиції</h2>
          <div class="grid">
            <div v-for="a in artworks" :key="a.id" class="cell">
              <div class="img-frame">
                <v-img v-if="a.imageUrl" :src="a.imageUrl" :alt="a.title" height="220" contain />
                <div v-else class="placeholder">—</div>
              </div>
              <div class="caption">{{ a.title }}</div>
            </div>
            <!-- Якщо менше 6 — показуємо порожні слоти для рівної сітки -->
            <div v-for="n in (6 - artworks.length)" :key="'ph-'+n" class="cell muted">
              <div class="img-frame"><div class="placeholder">—</div></div>
              <div class="caption"> </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
/* Уся сторінка — Cormorant Garamond */
.serif { font-family: "Cormorant Garamond", serif; }

.page { padding-top: 18px; padding-bottom: 28px; }
.mb-5 { margin-bottom: 24px; }

.meta { display: grid; gap: 6px; margin-bottom: 10px; }
.status {
  display: inline-block;
  font-size: 14px;
  padding: 2px 8px;
  border-radius: 999px;
  background: rgba(0,0,0,.06);
  color: rgba(0,0,0,.75);
  width: fit-content;
}
.title { font-size: clamp(32px, 4vw, 54px); line-height: 1.1; margin-top: 2px; }
.artist { font-size: 18px; }
.artist-link { color: inherit; text-decoration: underline; cursor: pointer; }
.dates { font-size: 16px; opacity: .8; }

.desc { margin-top: 12px; font-size: 18px; line-height: 1.6; }

.artworks { margin-top: 28px; }
.h { font-size: 24px; margin-bottom: 12px; }
.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
.cell { display: grid; gap: 6px; }
.placeholder {
  height: 220px;
  display:flex; align-items:center; justify-content:center;
  color: rgba(0,0,0,.35);
}
.caption { font-size: 16px; }

@media (max-width: 1100px) { .grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 700px)  { .grid { grid-template-columns: 1fr; } }
</style>
