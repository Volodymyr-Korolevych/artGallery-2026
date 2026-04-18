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
  <div class="art-card group flex flex-col sm:flex-row overflow-hidden">
    <!-- Image -->
    <div class="img-frame w-full sm:w-64 shrink-0 aspect-[4/3] sm:aspect-auto sm:h-auto overflow-hidden">
      <img v-if="coverUrl" :src="coverUrl" :alt="title"
        class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-[1.03]" />
      <div v-else
        class="w-full h-full min-h-[180px] flex items-center justify-center text-neutral-300 text-sm bg-neutral-50">
        —
      </div>
    </div>

    <!-- Body -->
    <div class="p-6 flex flex-col gap-2 flex-1 justify-center">
      <span class="status-badge upcoming self-start">Майбутня</span>
      <h3 class="font-serif text-2xl font-semibold leading-snug text-neutral-900 mt-1">{{ title }}</h3>
      <div v-if="artist" class="text-xs text-neutral-500 font-sans">
        <NuxtLink :to="'/artists/' + artist.slug" class="artist-link">{{ artist.fullName }}</NuxtLink>
      </div>
      <p v-if="short" class="text-sm text-neutral-600 leading-relaxed line-clamp-3 mt-1">{{ short }}</p>
      <div class="mt-4">
        <NuxtLink :to="'/exhibitions/' + slug" class="btn-outline text-xs px-5 py-2">
          Детальніше
        </NuxtLink>
      </div>
    </div>
  </div>
</template>
