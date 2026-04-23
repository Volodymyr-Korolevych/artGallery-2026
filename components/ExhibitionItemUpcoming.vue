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
    <!-- Image -->
    <div
      class="img-frame w-full md:w-72 shrink-0 aspect-[4/3] md:aspect-auto md:min-h-[260px] overflow-hidden bg-[var(--color-surface-soft)]">
      <img v-if="coverUrl" :src="coverUrl" :alt="title"
        class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-[1.03]" />
      <div v-else
        class="w-full h-full min-h-[180px] flex items-center justify-center text-sm text-[var(--color-text-muted)]">
        —
      </div>
    </div>

    <!-- Body -->
    <div class="p-5 md:p-6 flex flex-col justify-center gap-3 flex-1">
      <span class="status-badge upcoming self-start">Майбутня</span>

      <h3 class="leading-snug text-[var(--color-text)] group-hover:text-[var(--color-accent)] transition-colors">
        {{ title }}
      </h3>

      <div v-if="artist" class="text-sm text-[var(--color-text-soft)]">
        <NuxtLink :to="'/artists/' + artist.slug" class="artist-link">
          {{ artist.fullName }}
        </NuxtLink>
      </div>

      <p v-if="short" class="text-sm text-[var(--color-text-soft)] leading-relaxed line-clamp-3">
        {{ short }}
      </p>

      <div class="pt-2">
        <NuxtLink :to="'/exhibitions/' + slug" class="btn-ghost text-xs px-0">
          Детальніше →
        </NuxtLink>
      </div>
    </div>
  </div>
</template>