<script setup lang="ts">
type Artist = { id: number; fullName: string; slug: string }

const props = defineProps<{
  slug: string
  title: string
  startDate: string | null
  endDate: string | null
  cardUrl: string | null
  artist: Artist | null
}>()

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
  <NuxtLink :to="`/exhibitions/${slug}`"
    class="group block art-card opacity-[0.88] hover:opacity-100 transition-opacity">
    <!-- Image -->
    <div class="img-frame aspect-[4/3] overflow-hidden">
      <img v-if="cardUrl" :src="cardUrl" :alt="title"
        class="w-full h-full object-cover grayscale group-hover:grayscale-0 transition duration-500" />
      <div v-else class="w-full h-full flex items-center justify-center text-sm text-[var(--color-text-muted)]">
        Немає зображення
      </div>
    </div>

    <!-- Content -->
    <div class="p-5 space-y-3">

      <div class="text-[11px] tracking-[0.12em] text-[var(--color-text-muted)]">
        {{ fmtRange(startDate, endDate) }}
      </div>

      <h3 class="leading-snug">
        {{ title }}
      </h3>

      <div v-if="artist" class="text-sm text-[var(--color-text-soft)]">
        {{ artist.fullName }}
      </div>

      <div class="pt-1">
        <span class="btn-ghost text-xs px-0">
          Переглянути →
        </span>
      </div>

    </div>
  </NuxtLink>
</template>