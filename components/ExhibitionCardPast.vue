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
  <NuxtLink :to="`/exhibitions/${slug}`" class="group block art-card">
    <div class="img-frame aspect-[4/3] overflow-hidden">
      <img v-if="cardUrl" :src="cardUrl" :alt="title"
        class="w-full h-full object-cover grayscale group-hover:grayscale-0 transition duration-500" />
      <div v-else class="w-full h-full flex items-center justify-center text-sm text-[var(--color-text-muted)]">
        Немає зображення
      </div>
    </div>

    <div class="p-4 md:p-4 space-y-2.5">
      <div class="exhibition-status-text">
        Завершена виставка
      </div>

      <h3
        class="text-[1.28rem] md:text-[1.38rem] leading-[1.04] group-hover:text-[var(--color-accent)] transition-colors">
        {{ title }}
      </h3>

      <div v-if="artist" class="text-[16px] leading-snug font-semibold text-[var(--color-text)]">
        {{ artist.fullName }}
      </div>

      <div class="text-[12px] leading-snug text-[var(--color-text-muted)]">
        {{ fmtRange(startDate, endDate) }}
      </div>

      <div class="pt-1">
        <span
          class="inline-flex text-[13px] font-medium text-[var(--color-accent)] group-hover:text-[var(--color-accent-hover)] transition-colors">
          Детальніше →
        </span>
      </div>
    </div>
  </NuxtLink>
</template>

<style scoped>
.exhibition-status-text {
  font-size: 11px;
  line-height: 1.2;
  font-weight: 500;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--color-text-muted);
}
</style>