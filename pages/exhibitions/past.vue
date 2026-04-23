<script setup lang="ts">
definePageMeta({ layout: 'default' })
const supabase = useSupabaseClient()

type Exhibition = { id: number; slug: string; title: string; status: 'past' | 'current' | 'upcoming' | null; startDate: string | null; endDate: string | null; cardUrl: string | null; painterId: number | null; isPublished: boolean | null }
type Artist = { id: number; fullName: string; slug: string }

const loading = ref(true)
const items = ref<Exhibition[]>([])
const artistMap = ref<Record<number, Artist>>({})

const fetchPast = async () => {
  loading.value = true
  const { data: ex } = await supabase
    .from('exhibitions')
    .select('id,slug,title,status,"startDate","endDate","cardUrl","painterId","isPublished"')
    .eq('status', 'past')
    .eq('isPublished', true)
    .order('startDate', { ascending: false })

  items.value = (ex || []) as Exhibition[]

  const ids = [...new Set(items.value.map(x => x.painterId).filter(Boolean))] as number[]
  if (ids.length) {
    const { data: arts } = await supabase
      .from('artists')
      .select('id,"fullName",slug')
      .in('id', ids)

    const map: Record<number, Artist> = {}
      ; (arts || []).forEach((a: any) => { map[a.id] = a as Artist })
    artistMap.value = map
  }

  loading.value = false
}

onMounted(fetchPast)
const artistOf = (e: Exhibition) => e.painterId ? artistMap.value[e.painterId] || null : null
</script>

<template>
  <div class="container py-10 md:py-12 lg:py-14">

    <div class="max-w-3xl mb-8 md:mb-10">
      <div class="divider"></div>
      <h1 class="mb-3">
        Минулі виставки
      </h1>
      <p class="text-sm md:text-base text-[var(--color-text-muted)]">
        Архів експозицій галереї.
      </p>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      <div v-for="n in 6" :key="n" class="art-card">
        <div class="skeleton-img aspect-[4/3]"></div>
        <div class="p-5 space-y-3">
          <div class="skeleton-text w-24"></div>
          <div class="skeleton h-8 w-4/5"></div>
        </div>
      </div>
    </div>

    <!-- List -->
    <div v-else-if="items.length" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      <ExhibitionCardPast v-for="e in items" :key="e.id" :slug="e.slug" :title="e.title" :startDate="e.startDate"
        :endDate="e.endDate" :cardUrl="e.cardUrl" :artist="artistOf(e)" />
    </div>

    <!-- Empty -->
    <div v-else class="alert-info max-w-xl">
      Поки що немає завершених виставок.
    </div>

  </div>
</template>