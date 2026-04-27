<script setup lang="ts">
const supabase = useSupabaseClient()

type Exhibition = {
  id: number; title: string; slug: string; short: string | null; description: string | null
  startDate: string | null; endDate: string | null; coverUrl: string | null
  status: 'current' | 'past' | 'upcoming' | null; painterId: number | null; isPublished: boolean | null
}
type Artist = { id: number; fullName: string; slug: string }

const loading = ref(true)
const ex = ref<Exhibition | null>(null)
const artist = ref<Artist | null>(null)

const fetchCurrent = async () => {
  loading.value = true
  const { data, error } = await supabase
    .from('exhibitions')
    .select('id,title,slug,short,description,coverUrl,status,"startDate","endDate","painterId","isPublished"')
    .eq('status', 'current').eq('isPublished', true)
    .order('startDate', { ascending: false }).limit(1).maybeSingle()
  if (!error && data) {
    ex.value = data as Exhibition
    if (data.painterId) {
      const { data: a } = await supabase.from('artists').select('id,"fullName",slug').eq('id', data.painterId).maybeSingle()
      artist.value = (a as Artist) || null
    }
  } else { ex.value = null }
  loading.value = false
}

onMounted(fetchCurrent)

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
  <div class="min-h-screen flex flex-col">
    <main class="flex-1">

      <!-- Tab nav -->
      <div class="border-b border-[var(--color-accent)]/40">
        <div class="container flex gap-0 overflow-x-auto">
          <NuxtLink to="/exhibitions/past"
            class="px-5 md:px-6 py-4 text-[11px] tracking-[0.18em] uppercase text-[var(--color-text-muted)] border-b border-transparent hover:text-[var(--color-text)] hover:border-[var(--color-accent)] transition-all whitespace-nowrap">
            Минулі</NuxtLink>

          <button
            class="px-5 md:px-6 py-4 text-[11px] tracking-[0.18em] uppercase text-[var(--color-text)] border-b border-[var(--color-accent)] font-medium whitespace-nowrap">
            Поточна
          </button>

          <NuxtLink to="/exhibitions/upcoming"
            class="px-5 md:px-6 py-4 text-[11px] tracking-[0.18em] uppercase text-[var(--color-text-muted)] border-b border-transparent hover:text-[var(--color-text)] hover:border-[var(--color-accent)] transition-all whitespace-nowrap">
            Майбутні</NuxtLink>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="container py-12 md:py-14 lg:py-16">
        <div class="grid grid-cols-1 lg:grid-cols-5 gap-8 lg:gap-12 xl:gap-14 items-center">
          <div class="lg:col-span-2 space-y-4">
            <div class="skeleton-text w-24 h-3"></div>
            <div class="skeleton h-10 w-full"></div>
            <div class="skeleton h-10 w-4/5"></div>
            <div class="skeleton-text w-1/2 h-3"></div>
          </div>
          <div class="lg:col-span-3 skeleton-img h-[420px] md:h-[480px]"></div>
        </div>
      </div>

      <!-- Empty -->
      <div v-else-if="!ex" class="container py-12 md:py-14 lg:py-16">
        <div class="alert-info max-w-xl">
          Зараз немає позначеної поточної експозиції.
        </div>
      </div>

      <!-- Hero -->
      <div v-else class="container py-10 md:py-12 lg:py-14">
        <div class="grid grid-cols-1 lg:grid-cols-5 gap-8 lg:gap-10 xl:gap-12 items-center">

          <!-- LEFT -->
          <div class="lg:col-span-2 flex flex-col gap-5 max-w-xl">
            <div>
              <div class="divider"></div>

              <div class="text-[11px] tracking-[0.18em] uppercase text-[var(--color-text-muted)] mb-3">
                Поточна експозиція
              </div>

              <h1 class="font-serif leading-[0.98] text-[var(--color-text)]">
                {{ ex.title }}
              </h1>
            </div>

            <div v-if="ex.startDate || ex.endDate" class="text-sm text-[var(--color-text-muted)]">
              {{ fmtRange(ex.startDate, ex.endDate) }}
            </div>

            <p v-if="ex.short" class="text-[15px] md:text-base text-[var(--color-text-soft)] leading-relaxed">
              {{ ex.short }}
            </p>

            <div v-if="artist" class="text-sm text-[var(--color-text-muted)]">
              Художник:
              <NuxtLink :to="'/artists/' + artist.slug" class="artist-link ml-1">
                {{ artist.fullName }}
              </NuxtLink>
            </div>

            <div class="flex flex-wrap gap-3 pt-1">
              <NuxtLink :to="'/exhibitions/' + ex.slug" class="btn-outline text-xs">
                Детальніше
              </NuxtLink>
              <NuxtLink to="/tickets" class="btn-primary text-xs">
                Придбати квитки
              </NuxtLink>
            </div>
          </div>

          <!-- RIGHT -->
          <div class="lg:col-span-3 order-first lg:order-last">
            <div v-if="ex.coverUrl" class="flex items-center justify-center">
              <img :src="ex.coverUrl" :alt="ex.title" class="w-full max-h-[520px] object-contain" />
            </div>

            <div v-else
              class="h-[420px] md:h-[480px] flex items-center justify-center text-[var(--color-text-muted)] text-sm border border-[var(--color-line)]">
              Обкладинка відсутня
            </div>
          </div>

        </div>
      </div>

    </main>
  </div>
</template>