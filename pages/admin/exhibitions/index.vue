<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

type Exhibition = { id: number; title: string; painterId: number | null; coverUrl?: string | null; cardUrl?: string | null; startDate?: string | null; endDate?: string | null; isPublished?: boolean; status?: string }

const items = ref<Exhibition[]>([])
const artistsById = ref<Record<number, string>>({})
const fmtUA = (v: string | null | undefined) => v ? new Date(v).toLocaleDateString('uk-UA') : '—'

const fetchAll = async () => {
  const { data: exhs } = await supabase.from('exhibitions').select('*').order('createdAt', { ascending: false })
  items.value = exhs || []
  const { data: artists } = await supabase.from('artists').select('id,"fullName"')
  artistsById.value = {}
  for (const a of (artists || [])) artistsById.value[a.id] = a.fullName
}
onMounted(fetchAll)
</script>

<template>
  <div>
    <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-8">
      <div>
        <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-2">
          Адмін-панель
        </div>
        <h1 class="font-serif text-[2rem] md:text-[2.25rem] font-semibold text-[var(--color-text)] leading-none">
          Експозиції
        </h1>
      </div>

      <NuxtLink to="/admin/exhibitions/new" class="btn-primary text-xs self-start sm:self-auto">
        Додати виставку
      </NuxtLink>
    </div>

    <div class="art-card overflow-hidden">
      <div class="px-5 md:px-6 py-4 border-b border-[var(--color-line)] bg-[var(--color-surface-soft)]">
        <div class="grid grid-cols-[minmax(0,1fr)_auto] gap-4 items-center">
          <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)]">
            Усі експозиції
          </div>
          <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)]">
            Статус
          </div>
        </div>
      </div>

      <div v-if="items.length">
        <div v-for="e in items" :key="e.id"
          class="grid grid-cols-[88px_minmax(0,1fr)_auto] gap-4 md:gap-5 items-center px-5 md:px-6 py-4 md:py-5 border-b border-[color:rgba(188,197,203,0.25)] last:border-0 cursor-pointer hover:bg-[var(--color-accent-soft)]/40 transition-colors"
          @click="navigateTo('/admin/exhibitions/' + e.id)">
          <div class="w-[88px] h-[64px] shrink-0 img-frame">
            <img v-if="e.cardUrl" :src="e.cardUrl" class="w-full h-full object-cover" :alt="e.title || 'Експозиція'" />
            <div v-else class="w-full h-full flex items-center justify-center text-[var(--color-text-muted)] text-xs">
              —
            </div>
          </div>

          <div class="min-w-0">
            <div class="font-medium text-[var(--color-text)] truncate mb-1">
              {{ e.title || 'Без назви' }}
            </div>

            <div class="text-sm text-[var(--color-text-soft)] truncate">
              {{ artistsById[e.painterId || (-1 as any)] || '—' }}
            </div>

            <div class="text-[11px] tracking-[0.1em] uppercase text-[var(--color-text-muted)] mt-1.5">
              {{ fmtUA(e.startDate) }} — {{ fmtUA(e.endDate) }}
            </div>
          </div>

          <div class="shrink-0">
            <span v-if="e.isPublished" class="status-badge current">
              Опубліковано
            </span>
            <span v-else class="status-badge past">
              Чернетка
            </span>
          </div>
        </div>
      </div>

      <div v-else class="px-5 md:px-6 py-12 text-sm text-[var(--color-text-muted)] text-center italic">
        Немає виставок
      </div>
    </div>
  </div>
</template>