<script setup lang="ts">
definePageMeta({ layout: 'default' })
const supabase = useSupabaseClient()
const route = useRoute(); const router = useRouter()

type Exhibition = { id: number; slug: string; title: string; short: string | null; status: 'past' | 'current' | 'upcoming' | null; coverUrl: string | null; painterId: number | null; isPublished: boolean | null; startDate: string | null }
type Artist = { id: number; fullName: string; slug: string }

const loading = ref(true); const items = ref<Exhibition[]>([]); const artistMap = ref<Record<number, Artist>>({})
const pageSize = 4
const page = ref<number>(Number(route.query.page || 1) || 1)
watch(() => route.query.page, (q) => { const p = Number(q || 1) || 1; page.value = p < 1 ? 1 : p })

const fetchAll = async () => {
  loading.value = true
  const { data: ex } = await supabase.from('exhibitions').select('id,slug,title,short,status,coverUrl,"painterId","isPublished","startDate"').eq('isPublished', true).eq('status', 'upcoming').order('startDate', { ascending: true })
  items.value = (ex || []) as Exhibition[]
  const ids = [...new Set(items.value.map(x => x.painterId).filter(Boolean))] as number[]
  if (ids.length) {
    const { data: arts } = await supabase.from('artists').select('id,"fullName",slug').in('id', ids)
    const map: Record<number, Artist> = {}
      ; (arts || []).forEach((a: any) => { map[a.id] = a as Artist })
    artistMap.value = map
  }
  loading.value = false
}
onMounted(fetchAll)

const artistOf = (e: Exhibition) => e.painterId ? artistMap.value[e.painterId] || null : null
const pageCount = computed(() => Math.max(1, Math.ceil(items.value.length / pageSize)))
const paged = computed(() => { const start = (page.value - 1) * pageSize; return items.value.slice(start, start + pageSize) })
const goPage = (p: number) => { const safe = Math.min(Math.max(1, p), pageCount.value); router.replace({ query: { ...route.query, page: safe } }) }
</script>

<template>
  <div class="container py-10 md:py-12 lg:py-14">
    <div class="max-w-3xl mb-8 md:mb-10">
      <div class="divider"></div>
      <h1 class="mb-3">
        Майбутні експозиції
      </h1>
      <p class="text-sm md:text-base text-[var(--color-text-muted)] leading-relaxed">
        Найближчі анонсовані виставки галереї.
      </p>
    </div>

    <div v-if="loading" class="space-y-5">
      <div v-for="n in 3" :key="n" class="art-card animate-pulse overflow-hidden">
        <div class="flex flex-col md:flex-row">
          <div class="skeleton-img w-full md:w-72 h-52 md:h-auto md:min-h-[220px] shrink-0"></div>
          <div class="flex-1 p-5 md:p-6 space-y-3">
            <div class="skeleton-text w-24 h-3"></div>
            <div class="skeleton h-8 w-3/4 rounded"></div>
            <div class="skeleton-text w-full h-3"></div>
            <div class="skeleton-text w-4/5 h-3"></div>
          </div>
        </div>
      </div>
    </div>

    <div v-else>
      <div v-if="!items.length" class="alert-info max-w-xl">
        Наразі немає анонсованих експозицій.
      </div>

      <div class="space-y-5" v-else>
        <ExhibitionItemUpcoming v-for="e in paged" :key="e.id" :slug="e.slug" :title="e.title" :short="e.short"
          :coverUrl="e.coverUrl" :artist="artistOf(e)" />
      </div>

      <div v-if="pageCount > 1" class="flex items-center justify-center gap-4 mt-10">
        <button class="pager-btn" :disabled="page <= 1" @click="goPage(page - 1)">
          ← Попередня
        </button>

        <span class="text-xs text-[var(--color-text-muted)]">
          {{ page }} / {{ pageCount }}
        </span>

        <button class="pager-btn" :disabled="page >= pageCount" @click="goPage(page + 1)">
          Наступна →
        </button>
      </div>
    </div>
  </div>
</template>