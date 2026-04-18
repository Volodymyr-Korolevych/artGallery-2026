<script setup lang="ts">
const props = defineProps<{
  slug: string
  title: string
  startDate: string | null
  endDate: string | null
  cardUrl: string | null
  artist?: { fullName: string; slug: string } | null
}>()

const fmtRange = (s: string | null, e: string | null) => {
  const toD = (v: string | null) => v ? new Date(v) : null
  const f = (d: Date) => d.toLocaleDateString('uk-UA', { year: 'numeric', month: 'long', day: 'numeric' })
  const sd = toD(s), ed = toD(e)
  if (sd && ed) return `${f(sd)} — ${f(ed)}`
  if (sd) return f(sd)
  if (ed) return f(ed)
  return ''
}
</script>

<template>
  <div class="art-card group flex flex-col">
    <div class="img-frame aspect-[3/2] overflow-hidden">
      <img v-if="cardUrl" :src="cardUrl" :alt="title"
        class="w-full h-full object-contain bg-neutral-50 transition-transform duration-500 group-hover:scale-[1.02]" />
      <div v-else class="w-full h-full flex items-center justify-center text-neutral-300 text-sm">
        Зображення відсутнє
      </div>
    </div>

    <div class="p-4 flex flex-col gap-1.5 flex-1">
      <div class="text-xs text-neutral-400 font-sans">{{ fmtRange(startDate, endDate) }}</div>
      <h3 class="font-serif text-lg font-semibold leading-snug text-neutral-900">{{ title }}</h3>
      <div v-if="artist" class="text-xs text-neutral-500 font-sans">
        <NuxtLink :to="'/artists/' + artist.slug" class="artist-link">{{ artist.fullName }}</NuxtLink>
      </div>
      <div class="mt-auto pt-3">
        <NuxtLink :to="'/exhibitions/' + slug" class="btn-ghost text-xs px-0 py-1 underline underline-offset-2">
          Детальніше →
        </NuxtLink>
      </div>
    </div>
  </div>
</template>
