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
    <div class="img-frame aspect-[4/3] overflow-hidden">
      <img v-if="cardUrl" :src="cardUrl" :alt="title"
        class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-[1.03]" />
      <div v-else class="w-full h-full flex items-center justify-center text-sm text-[var(--color-text-muted)]">
        Зображення відсутнє
      </div>
    </div>

    <!-- Content -->
    <div class="p-5 md:p-6 space-y-3">

      <!-- Status + date -->
      <div class="flex items-center justify-between gap-4">
        <span v-if="statusLabel" class="status-badge" :class="statusClass">
          {{ statusLabel }}
        </span>

        <span v-if="startDate || endDate"
          class="text-[11px] tracking-[0.12em] text-[var(--color-text-muted)] whitespace-nowrap">
          {{ fmtRange(startDate, endDate) }}
        </span>
      </div>

      <!-- Title -->
      <h3 class="leading-snug group-hover:text-[var(--color-accent)] transition-colors">
        {{ title }}
      </h3>

      <!-- Artist -->
      <div v-if="artist" class="text-sm text-[var(--color-text-soft)]">
        {{ artist.fullName }}
      </div>

      <!-- CTA -->
      <div class="pt-2">
        <span class="btn-ghost text-xs px-0">
          Детальніше →
        </span>
      </div>

    </div>
  </NuxtLink>
</template>