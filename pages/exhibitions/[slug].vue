<script setup lang="ts">
const supabase = useSupabaseClient()
const route = useRoute()

type Exhibition = {
  id: number; title: string; description: string | null
  startDate: string | null; endDate: string | null
  coverUrl: string | null; painterId: number | null
}
type Artist = { id: number; fullName: string; slug: string }

const ex = ref<Exhibition | null>(null)
const artist = ref<Artist | null>(null)
const loading = ref(true)

const fetchExhibition = async () => {
  loading.value = true

  const { data } = await supabase
    .from('exhibitions')
    .select('*')
    .eq('slug', route.params.slug)
    .maybeSingle()

  ex.value = data as Exhibition

  if (data?.painterId) {
    const { data: a } = await supabase
      .from('artists')
      .select('id,"fullName",slug')
      .eq('id', data.painterId)
      .maybeSingle()

    artist.value = a as Artist
  }

  loading.value = false
}

onMounted(fetchExhibition)

const fmtRange = (s: string | null, e: string | null) => {
  const d = (v: string | null) => v ? new Date(v) : null
  const sD = d(s), eD = d(e)
  const f = (dt: Date) => dt.toLocaleDateString('uk-UA', { year: 'numeric', month: 'long', day: 'numeric' })
  if (sD && eD) return `${f(sD)} — ${f(eD)}`
  if (sD) return f(sD)
  if (eD) return f(eD)
  return ''
}
</script>

<template>
  <div class="container py-10 md:py-12 lg:py-14">

    <!-- Loading -->
    <div v-if="loading" class="space-y-6 animate-pulse">
      <div class="divider"></div>
      <div class="h-10 skeleton w-2/3"></div>
      <div class="h-4 skeleton w-1/2"></div>
      <div class="skeleton-img h-[420px]"></div>
    </div>

    <template v-else-if="ex">

      <!-- Header -->
      <div class="max-w-3xl mb-8 md:mb-10">
        <div class="divider"></div>

        <h1 class="mb-3">
          {{ ex.title }}
        </h1>

        <div class="text-sm text-[var(--color-text-muted)] mb-3">
          {{ fmtRange(ex.startDate, ex.endDate) }}
        </div>

        <div v-if="artist" class="text-sm text-[var(--color-text-soft)]">
          Художник:
          <NuxtLink :to="'/artists/' + artist.slug" class="artist-link ml-1">
            {{ artist.fullName }}
          </NuxtLink>
        </div>
      </div>

      <!-- Image -->
      <div class="img-frame mb-10 md:mb-12">
        <img v-if="ex.coverUrl" :src="ex.coverUrl" :alt="ex.title"
          class="w-full max-h-[520px] object-contain bg-[var(--color-surface-soft)]" />
        <div v-else class="h-[420px] flex items-center justify-center text-[var(--color-text-muted)] text-sm">
          Зображення відсутнє
        </div>
      </div>

      <!-- Description -->
      <div class="max-w-2xl space-y-4">
        <p v-if="ex.description" class="text-[15px] md:text-base leading-relaxed text-[var(--color-text-soft)]">
          {{ ex.description }}
        </p>
      </div>

    </template>

    <!-- Empty -->
    <div v-else class="alert-info max-w-xl">
      Виставку не знайдено.
    </div>

  </div>
</template>