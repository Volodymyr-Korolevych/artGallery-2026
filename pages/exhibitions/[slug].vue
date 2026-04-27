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

const loading = ref(true)
const ex = ref<Exhibition | null>(null)
const artist = ref<Artist | null>(null)

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
  } else {
    ex.value = null
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
      <div v-if="loading" class="container py-12">
        <div class="skeleton h-[420px] w-full mb-6"></div>
        <div class="skeleton h-6 w-1/3 mb-3"></div>
        <div class="skeleton h-6 w-1/2"></div>
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
        <div class="mb-6">
          <div class="divider"></div>

          <h1 class="font-serif mb-3">
            {{ ex.title }}
          </h1>

          <div class="text-sm text-[var(--color-text-muted)] mb-2">
            {{ fmtRange(ex.startDate, ex.endDate) }}
          </div>

          <div v-if="artist" class="text-sm text-[var(--color-text-muted)]">
            Художник:
            <NuxtLink :to="'/artists/' + artist.slug" class="artist-link ml-1">
              {{ artist.fullName }}
            </NuxtLink>
          </div>
        </div>

        <!-- IMAGE (ВИПРАВЛЕНО) -->
        <div v-if="ex.coverUrl" class="flex justify-center mb-8">
          <img :src="ex.coverUrl" :alt="ex.title" class="w-full max-w-[900px] max-h-[700px] object-contain" />
        </div>

        <!-- Description -->
        <div v-if="ex.description" class="max-w-3xl">
          <p class="text-[15px] md:text-base leading-relaxed text-[var(--color-text-soft)] whitespace-pre-line">
            {{ ex.description }}
          </p>
        </div>

      </div>

    </main>
  </div>
</template>