<script setup lang="ts">
const supabase = useSupabaseClient()
const route = useRoute()

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

type Artwork = {
  id: number
  title: string
  year: number | null
  imageUrl: string | null
  description: string | null
  isPublished: boolean | null
}

const loading = ref(true)
const ex = ref<Exhibition | null>(null)
const artist = ref<Artist | null>(null)
const artworks = ref<Artwork[]>([])

const fetchData = async () => {
  loading.value = true

  const { data, error } = await supabase
    .from('exhibitions')
    .select('*')
    .eq('slug', route.params.slug)
    .eq('isPublished', true)
    .maybeSingle()

  if (!error && data) {
    ex.value = data as Exhibition

    if (data.painterId) {
      const { data: a } = await supabase
        .from('artists')
        .select('id, fullName, slug')
        .eq('id', data.painterId)
        .maybeSingle()

      artist.value = a as Artist
    }

    const { data: works } = await supabase
      .from('artworks')
      .select('id, title, year, imageUrl, description, isPublished')
      .eq('exhibitionId', data.id)
      .eq('isPublished', true)
      .order('id', { ascending: true })
      .limit(6)

    artworks.value = (works || []) as Artwork[]
  } else {
    ex.value = null
    artworks.value = []
  }

  loading.value = false
}

onMounted(fetchData)

const fmtRange = (s: string | null, e: string | null) => {
  const d = (v: string | null) => (v ? new Date(v) : null)
  const sD = d(s)
  const eD = d(e)

  const f = (dt: Date) =>
    dt.toLocaleDateString('uk-UA', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })

  if (sD && eD) return `${f(sD)} — ${f(eD)}`
  if (sD) return f(sD)
  if (eD) return f(eD)
  return ''
}
</script>

<template>
  <div class="min-h-screen flex flex-col">
    <main class="flex-1">

      <!-- Loading -->
      <div v-if="loading" class="container py-10 md:py-12">
        <div class="max-w-3xl space-y-4">
          <div class="divider"></div>
          <div class="skeleton h-10 w-2/3"></div>
          <div class="skeleton h-4 w-1/2"></div>
          <div class="skeleton h-24 w-full mt-6"></div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 mt-12">
          <div v-for="n in 6" :key="n" class="art-card animate-pulse overflow-hidden">
            <div class="skeleton-img h-64"></div>
            <div class="p-4 space-y-3">
              <div class="skeleton h-5 w-2/3"></div>
              <div class="skeleton h-3 w-1/4"></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty -->
      <div v-else-if="!ex" class="container py-12">
        <div class="alert-info max-w-xl">
          Виставку не знайдено.
        </div>
      </div>

      <!-- Content -->
      <div v-else class="container py-10 md:py-12">

        <!-- Header -->
        <header class="max-w-3xl mb-10 md:mb-12">
          <div class="divider"></div>

          <h1 class="font-serif mb-4">
            {{ ex.title }}
          </h1>

          <div v-if="artist" class="text-[16px] text-[var(--color-text-soft)] mb-3">
            Художник:
            <NuxtLink :to="'/artists/' + artist.slug" class="artist-link ml-1">
              {{ artist.fullName }}
            </NuxtLink>
          </div>

          <div v-if="ex.startDate || ex.endDate" class="text-sm text-[var(--color-text-muted)] mb-6">
            {{ fmtRange(ex.startDate, ex.endDate) }}
          </div>

          <p v-if="ex.description"
            class="text-[15px] md:text-base leading-relaxed text-[var(--color-text-soft)] whitespace-pre-line">
            {{ ex.description }}
          </p>
        </header>

        <!-- Artworks -->
        <section v-if="artworks.length">
          <div class="divider"></div>

          <h2 class="font-serif text-2xl md:text-3xl mb-6 text-[var(--color-text)]">
            Роботи з експозиції
          </h2>

          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <article v-for="work in artworks" :key="work.id" class="art-card overflow-hidden">
              <div class="img-frame bg-transparent">
                <img v-if="work.imageUrl" :src="work.imageUrl" :alt="work.title" class="w-full h-64 object-contain" />
                <div v-else class="h-64 flex items-center justify-center text-sm text-[var(--color-text-muted)]">
                  Немає зображення
                </div>
              </div>

              <div class="p-4 space-y-1.5">
                <h3 class="font-serif text-[1.22rem] text-[var(--color-text)] leading-tight">
                  {{ work.title }}
                </h3>

                <div v-if="work.year" class="text-[12px] leading-snug text-[var(--color-text-muted)]">
                  {{ work.year }}
                </div>

                <p v-if="work.description"
                  class="text-sm leading-relaxed text-[var(--color-text-soft)] line-clamp-3 pt-1">
                  {{ work.description }}
                </p>
              </div>
            </article>
          </div>
        </section>

      </div>

    </main>
  </div>
</template>