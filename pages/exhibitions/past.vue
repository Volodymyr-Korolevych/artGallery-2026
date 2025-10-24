<script setup lang="ts">
const client = useSupabaseClient()
const { data: items } = await useAsyncData('exhPast', async () => {
  const { data } = await client.from('exhibitions').select('*').eq('status', 'past').eq('isPublished', true).order('endDate', { ascending: false })
  return data || []
})
</script>

<template>
  <div>
    <h1 class="text-h4 mb-4">Минулі експозиції</h1>
    <v-row>
      <v-col cols="12" md="4" v-for="exh in items" :key="exh.id">
        <v-card>
          <v-card-title>{{ exh.title }}</v-card-title>
          <v-card-subtitle>{{ exh.startDate }} — {{ exh.endDate }}</v-card-subtitle>
          <v-card-actions>
            <v-btn :to="'/exhibitions/' + exh.slug" color="primary">Детальніше</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>
