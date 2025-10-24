<script setup lang="ts">
definePageMeta({ middleware: 'auth' })
const client = useSupabaseClient()
const { data: items, refresh } = await useAsyncData('artistsAdmin', async () => {
  const { data } = await client.from('artists').select('*').order('fullName')
  return data || []
})
const model = ref<any>({ isPublished: true })
const dialog = ref(false)
async function save() {
  if (model.value.id) await client.from('artists').update(model.value).eq('id', model.value.id)
  else await client.from('artists').insert(model.value)
  dialog.value = false; model.value = { isPublished: true }; await refresh()
}
async function edit(it:any){ model.value = { ...it }; dialog.value = true }
async function del(id:number){ await client.from('artists').delete().eq('id', id); await refresh() }
</script>

<template>
  <div>
    <div class="d-flex justify-space-between align-center mb-4">
      <h1 class="text-h5">Художники</h1>
      <v-btn color="primary" @click="dialog=true">Додати</v-btn>
    </div>
    <v-data-table :items="items" :headers="[
      { title: 'Імʼя', key: 'fullName' },
      { title: 'Опубліковано', key: 'isPublished' }
    ]" />

    <v-dialog v-model="dialog" max-width="640">
      <v-card class="pa-4">
        <v-text-field v-model="model.fullName" label="Full Name" />
        <v-text-field v-model="model.slug" label="Slug" />
        <v-textarea v-model="model.bio" label="Bio" />
        <v-text-field v-model.number="model.birthYear" label="Birth Year" />
        <v-text-field v-model="model.country" label="Country" />
        <v-switch v-model="model.isPublished" label="Published" />
        <v-btn color="primary" @click="save">Зберегти</v-btn>
      </v-card>
    </v-dialog>
  </div>
</template>
