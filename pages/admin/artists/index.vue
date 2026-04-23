<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const items = ref<any[]>([])
const loading = ref(true)
const errorMsg = ref<string | null>(null)

const fetchArtists = async () => {
  loading.value = true
  const { data, error } = await supabase.from('artists').select('id,"fullName",country,birthYear,imageUrl').order('fullName')
  if (error) errorMsg.value = error.message
  items.value = data || []
  loading.value = false
}
onMounted(fetchArtists)
</script>

<template>
  <div>
    <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-8">
      <div>
        <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-2">
          Адмін-панель
        </div>
        <h1 class="font-serif text-[2rem] md:text-[2.25rem] font-semibold text-[var(--color-text)] leading-none">
          Художники
        </h1>
      </div>

      <NuxtLink to="/admin/artists/new" class="btn-primary text-xs self-start sm:self-auto">
        Додати художника
      </NuxtLink>
    </div>

    <div v-if="errorMsg" class="alert-error mb-6 max-w-2xl">{{ errorMsg }}</div>

    <div class="art-card overflow-hidden">
      <div class="px-5 md:px-6 py-4 border-b border-[var(--color-line)] bg-[var(--color-surface-soft)]">
        <div class="grid grid-cols-[minmax(0,1fr)_auto] gap-4 items-center">
          <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)]">
            Усі художники
          </div>
          <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)]">
            Деталі
          </div>
        </div>
      </div>

      <div v-if="loading" class="px-5 md:px-6 py-12 text-sm text-[var(--color-text-muted)] text-center">
        Завантаження...
      </div>

      <div v-else-if="!items.length"
        class="px-5 md:px-6 py-12 text-sm text-[var(--color-text-muted)] text-center italic">
        Немає художників
      </div>

      <div v-else>
        <div v-for="a in items" :key="a.id"
          class="grid grid-cols-[72px_minmax(0,1fr)_auto] gap-4 md:gap-5 items-center px-5 md:px-6 py-4 md:py-5 border-b border-[color:rgba(188,197,203,0.25)] last:border-0 cursor-pointer hover:bg-[var(--color-accent-soft)]/40 transition-colors"
          @click="navigateTo('/admin/artists/' + a.id)">
          <div class="w-[72px] h-[72px] shrink-0 img-frame">
            <img v-if="a.imageUrl" :src="a.imageUrl" class="w-full h-full object-cover" />
            <div v-else
              class="w-full h-full flex items-center justify-center font-serif text-2xl text-[var(--color-text-muted)]/40">
              {{ a.fullName?.[0] }}
            </div>
          </div>

          <div class="min-w-0">
            <div class="font-medium text-[var(--color-text)] truncate mb-1">
              {{ a.fullName }}
            </div>

            <div class="text-sm text-[var(--color-text-soft)] truncate">
              {{ a.country || '—' }}
              <span v-if="a.birthYear"> · {{ a.birthYear }}</span>
            </div>
          </div>

          <svg class="w-4 h-4 text-[var(--color-text-muted)]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5l7 7-7 7" />
          </svg>
        </div>
      </div>
    </div>
  </div>
</template>