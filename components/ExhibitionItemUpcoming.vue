<script setup lang="ts">
const props = defineProps<{
  slug: string
  title: string
  short: string | null
  coverUrl: string | null
  artist?: { fullName: string; slug: string } | null
}>()
</script>

<template>
  <div class="art-card group flex flex-col md:flex-row overflow-hidden">
    <div
      class="img-frame w-full md:w-72 shrink-0 aspect-[4/3] md:aspect-auto md:min-h-[260px] overflow-hidden bg-[var(--color-surface-soft)]">
      <img v-if="coverUrl" :src="coverUrl" :alt="title"
        class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-[1.03]" />
      <div v-else
        class="w-full h-full min-h-[180px] flex items-center justify-center text-sm text-[var(--color-text-muted)]">
        —
      </div>
    </div>

    <div class="p-5 md:p-6 flex flex-col justify-center gap-2.5 flex-1">
      <div class="exhibition-status-text">
        Майбутня виставка
      </div>

      <h3 class="leading-snug text-[var(--color-text)] group-hover:text-[var(--color-accent)] transition-colors">
        {{ title }}
      </h3>

      <div v-if="artist" class="text-[16px] leading-snug font-semibold">
        <NuxtLink :to="'/artists/' + artist.slug" class="artist-link">
          {{ artist.fullName }}
        </NuxtLink>
      </div>

      <p v-if="short" class="text-sm text-[var(--color-text-muted)] leading-relaxed line-clamp-3">
        {{ short }}
      </p>

      <div class="pt-1">
        <NuxtLink :to="'/exhibitions/' + slug"
          class="inline-flex text-[13px] font-medium text-[var(--color-accent)] hover:text-[var(--color-accent-hover)] transition-colors">
          Детальніше →
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<style scoped>
.exhibition-status-text {
  font-size: 11px;
  line-height: 1.2;
  font-weight: 500;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--color-accent);
}
</style>