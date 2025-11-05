<script setup lang="ts">
// Головна: поточна експозиція (герой-блок) + навігаційні "таби": Минулі / Поточна / Майбутні
// Вимоги: ліворуч 1/3 — назва, короткий опис, художник (лінк), кнопки;
// праворуч 2/3 — зображення (coverUrl), contain, фіксована висота hero.
// "Поточна" виділена, інші клікабельні.  [ТЗ: Головне меню/UI вимоги]
const supabase = useSupabaseClient()

type Exhibition = {
  id: number
  title: string
  slug: string
  short: string | null
  description: string | null
  startDate: string | null
  endDate: string | null
  coverUrl: string | null
  status: 'current' | 'past' | 'upcoming' | null
  painterId: number | null
  isPublished: boolean | null
}
type Artist = {
  id: number
  fullName: string
  slug: string
}

const loading = ref(true)
const ex = ref<Exhibition | null>(null)
const artist = ref<Artist | null>(null)

const fetchCurrent = async () => {
  loading.value = true
  // Поточна експозиція: статус = 'current' і isPublished = true
  const { data, error } = await supabase
    .from('exhibitions')
    .select('id,title,slug,short,description,coverUrl,status,"startDate","endDate","painterId","isPublished"')
    .eq('status', 'current')
    .eq('isPublished', true)
    .order('startDate', { ascending: false })
    .limit(1)
    .maybeSingle()
  if (!error && data) {
    ex.value = data as Exhibition
    if (data.painterId) {
      const { data: a } = await supabase
        .from('artists')
        .select('id,"fullName",slug')
        .eq('id', data.painterId)
        .maybeSingle()
      artist.value = (a as Artist) || null
    }
  } else {
    ex.value = null
  }
  loading.value = false
}

onMounted(fetchCurrent)

const goPast = () => navigateTo('/exhibitions/past')
const goCurrent = () => {} // вже тут
const goUpcoming = () => navigateTo('/exhibitions/upcoming')
const goDetails = () => { if (ex.value?.slug) navigateTo('/exhibitions/' + ex.value.slug) }
const goTickets = () => navigateTo('/tickets')
const goArtist = () => { if (artist.value?.slug) navigateTo('/artists/' + artist.value.slug) }

const fmtRange = (s: string | null, e: string | null) => {
  const d = (v: string | null) => (v ? new Date(v) : null)
  const sD = d(s), eD = d(e)
  const f = (dt: Date) => dt.toLocaleDateString('uk-UA', { year: 'numeric', month: 'long', day: 'numeric' })
  if (sD && eD) return `${f(sD)} — ${f(eD)}`
  if (sD) return f(sD)
  if (eD) return f(eD)
  return ''
}
</script>

<template>
  <div class="page">
    <!-- Навігаційні "таби": Минулі / Поточна / Майбутні -->
    <div class="tabs">
      <button class="tab" @click="goPast">Минулі</button>
      <button class="tab active" @click="goCurrent">Поточна</button>
      <button class="tab" @click="goUpcoming">Майбутні</button>
    </div>

    <v-skeleton-loader v-if="loading" type="image, article"></v-skeleton-loader>

    <div v-else>
      <v-alert v-if="!ex" type="info" variant="tonal" class="mb-4">
        Зараз немає позначеної поточної експозиції. Перейдіть до розділів «Минулі» або «Майбутні».
      </v-alert>

      <div v-if="ex" class="hero">
        <!-- Ліва колонка (1/3) -->
        <div class="left">
          <h1 class="title">{{ ex.title }}</h1>
          <div v-if="ex.startDate || ex.endDate" class="dates">{{ fmtRange(ex.startDate, ex.endDate) }}</div>

          <div class="short" v-if="ex.short">{{ ex.short }}</div>

          <div class="artist" v-if="artist">
            Художник:
            <a class="artist-link" @click.prevent="goArtist">{{ artist.fullName }}</a>
          </div>

          <div class="cta">
            <v-btn color="primary" @click="goDetails">Детальніше</v-btn>
            <v-btn variant="tonal" class="ml-2" @click="goTickets">Придбати квитки</v-btn>
          </div>
        </div>

        <!-- Права колонка (2/3) -->
        <div class="right">
          <div class="imgWrap" v-if="ex.coverUrl">
            <v-img :src="ex.coverUrl" :alt="ex.title" class="hero-img" height="520" contain />
          </div>
          <div v-else class="imgPlaceholder">
            Обкладинка відсутня
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 24px; }
.tabs { display:flex; justify-content:center; gap:24px; margin-top:8px; }
.tab {
  background: transparent; border: 0; padding: 4px 8px; cursor: pointer; font-weight: 600; opacity: .75;
}
.tab:hover { opacity: 1; }
.tab.active { color: #1e40af; opacity: 1; } /* акцентний синій */

.hero { display: grid; grid-template-columns: 1fr 2fr; gap: 24px; align-items: center; }
.left { display: grid; gap: 16px; }
.title { font-size: clamp(28px, 3.2vw, 44px); line-height: 1.1; }
.dates { opacity: .75; }
.short { font-size: 16px; line-height: 1.5; }
.artist { font-size: 15px; }
.artist-link { color: inherit; text-decoration: underline; cursor: pointer; }
.cta { display: flex; align-items: center; }

.right { display:flex; justify-content: flex-end; }
.imgWrap { width: 100%; display:flex; justify-content: flex-end; }
.hero-img { width: 100%; max-height: 520px; }
.imgPlaceholder {
  height: 520px; width: 100%; display:flex; align-items:center; justify-content:center;
  border: 1px dashed rgba(0,0,0,.2); border-radius: 12px; color: rgba(0,0,0,.5);
}

@media (max-width: 1200px) {
  .hero { grid-template-columns: 1fr; }
  .right { order: -1; } /* як у референсі, дозволяє назві перекривати зображення на деяких ширинах */
}
</style>
