<script setup lang="ts">
const route = useRoute()
const client = useSupabaseClient()
const { data: artist } = await useAsyncData('artist', async () => {
  const { data } = await client.from('artists').select('*').eq('slug', route.params.slug).maybeSingle()
  return data
})
const { data: works } = await useAsyncData('artistWorks', async () => {
  if (!artist.value) return []
  const { data } = await client.from('artworks').select('*').eq('artistId', artist.value.id).eq('isPublished', true)
  return data || []
})
</script>

<template>
  <div v-if="artist">
    <h1 class="text-h4">{{ artist.fullName }}</h1>
    <p class="text-body-2">{{ artist.bio }}</p>
    <h3 class="text-h6 mt-6">Роботи</h3>
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
