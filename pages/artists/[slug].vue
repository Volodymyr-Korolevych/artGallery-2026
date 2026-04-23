<script setup lang="ts">
definePageMeta({ layout: 'default' })
const route = useRoute()
const supabase = useSupabaseClient()

type Artist = { id: number; slug: string; fullName: string; description: string | null; birthYear: number | null; country: string | null; imageUrl: string | null }
type Artwork = { id: number; title: string; imageUrl: string | null; exhibitionId: number; year?: number | null; description?: string | null }
type Exhibition = { id: number; title: string; slug: string }

const loading = ref(true)
const artist = ref<Artist | null>(null)
const artworks = ref<Artwork[]>([])
const exMap = ref<Record<number, Exhibition>>({})

const fetchData = async () => {
  loading.value = true
  const slug = String(route.params.slug)
  const { data: a } = await supabase.from('artists').select('id,slug,"fullName",description,"birthYear",country,"imageUrl"').eq('slug', slug).maybeSingle()
  if (!a) { loading.value = false; return }
  artist.value = a as Artist
  const { data: aw } = await supabase.from('artworks').select('id,title,year,imageUrl,description,"exhibitionId"').eq('artistId', a.id).order('exhibitionId', { ascending: false })
  artworks.value = (aw || []) as Artwork[]
  const exIds = [...new Set(artworks.value.map(x => x.exhibitionId).filter(Boolean))]
  if (exIds.length) {
    const { data: exs } = await supabase.from('exhibitions').select('id,title,slug').in('id', exIds)
    const map: Record<number, Exhibition> = {}
      ; (exs || []).forEach((e: any) => { map[e.id] = e as Exhibition })
    exMap.value = map
  }
  loading.value = false
}
onMounted(fetchData)
</script>

<template>
  <div class="container py-10 md:py-12 lg:py-14">
    <!-- Loading -->
    <div v-if="loading" class="animate-pulse space-y-6">
      <div class="divider"></div>
      <div class="h-10 skeleton w-1/3"></div>
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12 items-start">
        <div class="space-y-3">
          <div class="h-4 skeleton w-full"></div>
          <div class="h-4 skeleton w-5/6"></div>
          <div class="h-4 skeleton w-4/5"></div>
        </div>
        <div class="skeleton-img h-[420px] md:h-[520px]"></div>
      </div>
    </div>

    <template v-else>
      <div v-if="!artist" class="alert-error max-w-xl">
        Художника не знайдено.
      </div>

      <div v-if="artist">
        <!-- Top section -->
        <div
          class="grid grid-cols-1 lg:grid-cols-[minmax(0,0.95fr)_minmax(320px,1.05fr)] gap-10 lg:gap-14 items-start mb-12 md:mb-14">
          <!-- Left -->
          <div class="order-2 lg:order-1 max-w-2xl">
            <div class="divider"></div>

            <h1 class="mb-6">
              {{ artist.fullName }}
            </h1>

            <div class="space-y-6">
              <div v-if="artist.description">
                <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-3">
                  Про художника
                </div>
                <div class="text-[15px] md:text-base text-[var(--color-text-soft)] leading-relaxed"
                  v-html="artist.description.replace(/\n/g, '<br/>')"></div>
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 pt-1">
                <div v-if="artist.birthYear" class="art-card p-5">
                  <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-2">
                    Рік народження
                  </div>
                  <div class="font-serif text-[1.25rem] text-[var(--color-text)]">
                    {{ artist.birthYear }}
                  </div>
                </div>

                <div v-if="artist.country" class="art-card p-5">
                  <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-2">
                    Країна
                  </div>
                  <div class="font-serif text-[1.25rem] text-[var(--color-text)]">
                    {{ artist.country }}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Right: portrait -->
          <div class="order-1 lg:order-2 img-frame overflow-hidden bg-[var(--color-surface)]">
            <img v-if="artist.imageUrl" :src="artist.imageUrl" :alt="artist.fullName"
              class="w-full max-h-[560px] object-cover" />
            <div v-else
              class="h-[420px] md:h-[520px] flex items-center justify-center text-[var(--color-text-muted)]/40">
              <span class="font-serif text-7xl">{{ artist.fullName[0] }}</span>
            </div>
          </div>
        </div>

        <!-- Artworks -->
        <div>
          <div class="max-w-2xl mb-7">
            <h2 class="mb-2">
              Роботи в експозиціях галереї
            </h2>
            <p class="text-sm md:text-base text-[var(--color-text-muted)]">
              Добірка робіт, пов’язаних із виставками галереї.
            </p>
          </div>

          <div v-if="!artworks.length" class="alert-info max-w-xl">
            Наразі немає робіт для показу.
          </div>

          <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 md:gap-7">
            <div v-for="w in artworks" :key="w.id" class="art-card overflow-hidden">
              <div class="img-frame aspect-[4/3] overflow-hidden">
                <img v-if="w.imageUrl" :src="w.imageUrl" :alt="w.title"
                  class="w-full h-full object-contain bg-[var(--color-surface-soft)]" />
                <div v-else
                  class="w-full h-full flex items-center justify-center text-[var(--color-text-muted)] text-sm">
                  —
                </div>
              </div>

              <div class="p-4 md:p-5 space-y-2">
                <div class="font-serif text-[1.15rem] text-[var(--color-text)] leading-snug">
                  {{ w.title }}
                </div>

                <div v-if="w.year" class="text-[11px] tracking-[0.12em] uppercase text-[var(--color-text-muted)]">
                  {{ w.year }}
                </div>

                <div v-if="w.description" class="text-sm text-[var(--color-text-soft)] leading-relaxed">
                  {{ w.description }}
                </div>

                <div v-if="exMap[w.exhibitionId]" class="text-xs text-[var(--color-text-muted)] pt-1">
                  з експозиції:
                  <NuxtLink :to="'/exhibitions/' + exMap[w.exhibitionId].slug" class="artist-link ml-1">
                    {{ exMap[w.exhibitionId].title }}
                  </NuxtLink>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>