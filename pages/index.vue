<script setup lang="ts">
const { data: current } = await useAsyncData('currentExhibition', async () => {
  const client = useSupabaseClient()
  const { data, error } = await client
    .from('exhibitions')
    .select('*')
    .eq('status', 'current')
    .eq('isPublished', true)
    .limit(1)
    .single()
  if (error) return null
  return data
})
</script>

<template>
  <div>
    <h1 class="text-h4 mb-4">Поточна експозиція</h1>
    <v-alert v-if="!current" type="info" text>Зараз немає поточної експозиції.</v-alert>
    <v-card v-else class="pa-4">
      <div class="text-h5">{{ current.title }}</div>
      <div class="text-body-2">{{ current.description }}</div>
      <v-btn :to="'/exhibitions/' + current.slug" class="mt-3" color="primary">Детально</v-btn>
      <v-btn to="/tickets" class="mt-3 ml-2" color="primary" variant="tonal">Придбати квиток</v-btn>
    </v-card>
  </div>
</template>
