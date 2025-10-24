<script setup lang="ts">
const client = useSupabaseClient()
const { data: items } = await useAsyncData('artists', async () => {
  const { data } = await client.from('artists').select('*').eq('isPublished', true).order('fullName')
  return data || []
})
</script>

<template>
  <div>
    <h1 class="text-h4 mb-4">Художники</h1>
    <v-row>
      <v-col cols="12" md="4" v-for="a in items" :key="a.id">
        <v-card :to="'/artists/' + a.slug">
          <v-card-title>{{ a.fullName }}</v-card-title>
          <v-card-text class="text-truncate-2">{{ a.bio }}</v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>
