<script setup lang="ts">
const props = defineProps<{
  slug: string
  title: string
  status: 'past' | 'current' | 'upcoming' | null
  startDate: string | null
  endDate: string | null
  cardUrl: string | null
  artist?: { fullName: string, slug: string } | null
}>()

const statusLabel = (s: any) => s === 'past' ? 'Минула' : s === 'current' ? 'Поточна' : s === 'upcoming' ? 'Майбутня' : ''
const statusClass = (s: any) => s === 'current' ? 'current' : s === 'upcoming' ? 'upcoming' : 'past'

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
    <!-- Image -->
    <div class="img-frame aspect-[4/3] overflow-hidden">
      <img v-if="cardUrl" :src="cardUrl" :alt="title"
        class="w-full h-full object-contain bg-neutral-50 transition-transform duration-500 group-hover:scale-[1.02]" />
      <div v-else class="w-full h-full flex items-center justify-center text-neutral-300 text-sm">
        Зображення відсутнє
      </div>
    </div>

    <!-- Body -->
    <div class="p-5 flex flex-col gap-2 flex-1">
      <div class="flex items-center justify-between">
        <span v-if="status" :class="['status-badge', statusClass(status)]">{{ statusLabel(status) }}</span>
        <span v-if="startDate || endDate" class="text-xs text-neutral-400 font-sans">
          {{ fmtRange(startDate, endDate) }}
        </span>
      </div>

      <h3 class="font-serif text-xl font-semibold leading-snug text-neutral-900 mt-1">{{ title }}</h3>

      <div v-if="artist" class="text-xs text-neutral-500 font-sans">
        <NuxtLink :to="'/artists/' + artist.slug" class="artist-link">{{ artist.fullName }}</NuxtLink>
      </div>

      <div class="mt-auto pt-3">
        <NuxtLink :to="'/exhibitions/' + slug" class="btn-outline text-xs px-4 py-2">
          Детальніше
        </NuxtLink>
      </div>
    </div>
  </div>
</template>
