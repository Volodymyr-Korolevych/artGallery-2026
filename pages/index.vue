<script setup lang="ts">
const supabase = useSupabaseClient()

type Exhibition = {
  id: number; title: string; slug: string; short: string|null; description: string|null
  startDate: string|null; endDate: string|null; coverUrl: string|null
  status: 'current'|'past'|'upcoming'|null; painterId: number|null; isPublished: boolean|null
}
type Artist = { id: number; fullName: string; slug: string }

const loading = ref(true)
const ex = ref<Exhibition|null>(null)
const artist = ref<Artist|null>(null)

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

const fmtRange = (s: string|null, e: string|null) => {
  const d = (v: string|null) => (v ? new Date(v) : null)
  const sD = d(s), eD = d(e)
  const f = (dt: Date) => dt.toLocaleDateString('uk-UA', { year:'numeric', month:'long', day:'numeric' })
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
      <div class="border-b border-neutral-100 bg-white">
        <div class="container flex gap-0">
          <NuxtLink
            to="/exhibitions/past"
            class="px-6 py-4 text-xs tracking-widest uppercase text-neutral-400 hover:text-neutral-900 border-b-2 border-transparent hover:border-neutral-300 transition-all"
          >Минулі</NuxtLink>
          <button
            class="px-6 py-4 text-xs tracking-widest uppercase text-neutral-900 border-b-2 border-neutral-900 font-medium"
          >Поточна</button>
          <NuxtLink
            to="/exhibitions/upcoming"
            class="px-6 py-4 text-xs tracking-widest uppercase text-neutral-400 hover:text-neutral-900 border-b-2 border-transparent hover:border-neutral-300 transition-all"
          >Майбутні</NuxtLink>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="container py-16">
        <div class="grid grid-cols-1 lg:grid-cols-5 gap-10 lg:gap-16 items-center">
          <div class="lg:col-span-2 space-y-4">
            <div class="skeleton-text w-2/3 h-3"></div>
            <div class="skeleton h-12 w-full rounded"></div>
            <div class="skeleton h-12 w-4/5 rounded"></div>
            <div class="skeleton-text w-1/2 h-3"></div>
            <div class="skeleton-text w-3/4 h-3"></div>
          </div>
          <div class="lg:col-span-3 skeleton-img h-[480px] rounded"></div>
        </div>
      </div>

      <!-- Empty state -->
      <div v-else-if="!ex" class="container py-16">
        <div class="alert-info max-w-lg">
          Зараз немає позначеної поточної експозиції. Перейдіть до розділів «Минулі» або «Майбутні».
        </div>
      </div>

      <!-- Hero -->
      <div v-else class="container py-12 lg:py-16">
        <div class="grid grid-cols-1 lg:grid-cols-5 gap-10 lg:gap-16 items-center">

          <!-- Left: info -->
          <div class="lg:col-span-2 flex flex-col gap-5">
            <div>
              <div class="divider"></div>
              <div class="text-xs tracking-widest uppercase text-neutral-400 mb-3">Поточна експозиція</div>
              <h1 class="font-serif text-4xl lg:text-5xl xl:text-6xl font-semibold leading-[1.05] text-neutral-900">
                {{ ex.title }}
              </h1>
            </div>

            <div v-if="ex.startDate || ex.endDate" class="text-sm text-neutral-500 font-sans">
              {{ fmtRange(ex.startDate, ex.endDate) }}
            </div>

            <p v-if="ex.short" class="text-base text-neutral-600 leading-relaxed">{{ ex.short }}</p>

            <div v-if="artist" class="text-sm text-neutral-500 font-sans">
              Художник:
              <NuxtLink :to="'/artists/' + artist.slug" class="artist-link ml-1">{{ artist.fullName }}</NuxtLink>
            </div>

            <div class="flex flex-wrap gap-3 mt-2">
              <NuxtLink :to="'/exhibitions/' + ex.slug" class="btn-primary text-xs">
                Детальніше
              </NuxtLink>
              <NuxtLink to="/tickets" class="btn-outline text-xs">
                Придбати квитки
              </NuxtLink>
            </div>
          </div>

          <!-- Right: image -->
          <div class="lg:col-span-3 order-first lg:order-last">
            <div class="img-frame overflow-hidden" v-if="ex.coverUrl">
              <img
                :src="ex.coverUrl"
                :alt="ex.title"
                class="w-full max-h-[540px] object-contain bg-neutral-50"
              />
            </div>
            <div v-else class="img-frame h-[480px] flex items-center justify-center text-neutral-300 text-sm">
              Обкладинка відсутня
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
