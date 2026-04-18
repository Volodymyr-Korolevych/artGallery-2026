<script setup lang="ts">
definePageMeta({ layout: 'default' })
const client = useSupabaseClient()
const { data: items } = await useAsyncData('exhCurrent', async () => {
  const { data } = await client.from('exhibitions').select('*').eq('status','current').eq('isPublished',true)
  return data || []
})
</script>

<template>
  <div>
    <div class="divider"></div>
    <h1 class="font-serif text-5xl font-semibold text-neutral-900 mb-10">Поточна експозиція</h1>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div v-for="exh in items" :key="exh.id" class="art-card p-6">
        <h3 class="font-serif text-2xl font-semibold text-neutral-900 mb-3">{{ exh.title }}</h3>
        <p class="text-sm text-neutral-600 leading-relaxed mb-5">{{ exh.description }}</p>
        <NuxtLink :to="'/exhibitions/'+exh.slug" class="btn-outline text-xs">Детальніше</NuxtLink>
      </div>
    </div>
    <div v-if="!items?.length" class="text-sm text-neutral-400 italic">Немає поточної виставки.</div>
  </div>
</template>
