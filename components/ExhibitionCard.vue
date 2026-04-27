<script setup lang="ts">
type Artist = { id: number; fullName: string; slug: string }

const props = defineProps<{
  slug: string
  title: string
  status: 'past' | 'current' | 'upcoming' | null
  startDate: string | null
  endDate: string | null
  cardUrl: string | null
  artist: Artist | null
}>()

const statusLabel = computed(() => {
  if (props.status === 'current') return 'Поточна'
  if (props.status === 'upcoming') return 'Майбутня'
  if (props.status === 'past') return 'Завершена'
  return ''
})

const statusClass = computed(() => {
  if (props.status === 'current') return 'current'
  if (props.status === 'upcoming') return 'upcoming'
  if (props.status === 'past') return 'past'
  return ''
})

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
  <NuxtLink :to="`/exhibitions/${slug}`" class="group block art-card">
    <!-- Image -->
    <div class="overflow-hidden bg-transparent border-b border-[var(--color-line)]">
      <img v-if="cardUrl" :src="cardUrl" :alt="title"
        class="w-full aspect-[4/3] object-cover transition-transform duration-500 group-hover:scale-[1.025]" />
      <div v-else
        class="w-full aspect-[4/3] flex items-center justify-center text-sm text-[var(--color-text-muted)] bg-[var(--color-surface-soft)]">
        Зображення відсутнє
      </div>
    </div>

    <!-- Content -->
    <div class="p-4 md:p-5 space-y-2.5">
      <!-- Status + date -->
      <div class="flex flex-wrap items-center gap-2.5">
        <span v-if="statusLabel" class="status-badge" :class="statusClass">
          {{ statusLabel }}
        </span>

        <span v-if="startDate || endDate"
          class="text-[11px] leading-snug tracking-[0.08em] text-[var(--color-text-muted)]">
          {{ fmtRange(startDate, endDate) }}
        </span>
      </div>

      <!-- Title -->
      <h3
        class="text-[1.35rem] md:text-[1.45rem] leading-[1.05] group-hover:text-[var(--color-accent)] transition-colors">
        {{ title }}
      </h3>

      <!-- Artist -->
      <div v-if="artist" class="text-[15px] leading-snug text-[var(--color-text-soft)]">
        {{ artist.fullName }}
      </div>

      <!-- CTA -->
      <div class="pt-1">
        <span class="btn-ghost text-xs px-0 py-0">
          Детальніше →
        </span>
      </div>
    </div>
  </NuxtLink>
</template>