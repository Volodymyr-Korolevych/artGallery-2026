<script setup lang="ts">
definePageMeta({ middleware: 'auth' })
const client = useSupabaseClient()
const { data: items, refresh } = await useAsyncData('artworksAdmin', async () => {
  const { data } = await client.from('artworks').select('*').order('year', { ascending: false })
  return data || []
})
const model = ref<any>({ isPublished: true })
const dialog = ref(false)
async function save() {
  if (model.value.id) await client.from('artworks').update(model.value).eq('id', model.value.id)
  else await client.from('artworks').insert(model.value)
  dialog.value = false; model.value = { isPublished: true }; await refresh()
}
async function edit(it:any){ model.value = { ...it }; dialog.value = true }
async function del(id:number){ await client.from('artworks').delete().eq('id', id); await refresh() }
</script>

<template>
  <div>
    <div class="d-flex justify-space-between align-center mb-4">
      <h1 class="text-h5">Роботи</h1>
      <v-btn color="primary" @click="dialog=true">Додати</v-btn>
    </div>
    <v-data-table :items="items" :headers="[
      { title: 'Назва', key: 'title' },
      { title: 'Рік', key: 'year' }
    ]" />

    <v-dialog v-model="dialog" max-width="640">
      <v-card class="pa-4">
        <v-text-field v-model="model.title" label="Title" />
        <v-text-field v-model.number="model.year" label="Year" />
        <v-textarea v-model="model.description" label="Description" />
        <v-text-field v-model.number="model.artistId" label="Artist ID" />
        <v-text-field v-model.number="model.exhibitionId" label="Exhibition ID" />
        <v-switch v-model="model.isPublished" label="Published" />
        <v-btn color="primary" @click="save">Зберегти</v-btn>
      </v-card>
    </v-dialog>
  </div>
</template>
