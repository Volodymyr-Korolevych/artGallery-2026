<script setup lang="ts">
const route = useRoute()
const client = useSupabaseClient()

const { data: exhibition } = await useAsyncData('exhBySlug', async () => {
  const { data } = await client.from('exhibitions').select('*').eq('slug', route.params.slug).maybeSingle()
  return data
})
const { data: artist } = await useAsyncData('artistByExh', async () => {
  if (!exhibition.value?.painterId) return null
  const { data } = await client.from('artists').select('*').eq('id', exhibition.value.painterId).maybeSingle()
  return data
})
const { data: works } = await useAsyncData('works', async () => {
  const { data } = await client.from('artworks').select('*').eq('exhibitionId', exhibition.value?.id).eq('isPublished', true).limit(6)
  return data || []
})
</script>

<template>
  <div v-if="exhibition">
    <h1 class="text-h4">{{ exhibition.title }}</h1>
    <p class="text-body-2">{{ exhibition.description }}</p>
    <div v-if="artist" class="mt-4">
      <div class="text-h6">Художник: {{ artist.fullName }}</div>
      <div class="text-body-2">{{ artist.bio }}</div>
    </div>
    <h3 class="text-h6 mt-6">Роботи (до 6)</h3>
    <v-row>
      <v-col cols="12" md="4" v-for="w in works" :key="w.id">
        <v-card>
          <v-card-title>{{ w.title }}</v-card-title>
          <v-card-text>{{ w.description }}</v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>
