<script setup lang="ts">
definePageMeta({ middleware: 'auth' })
const client = useSupabaseClient()
const { data: items, refresh } = await useAsyncData('exhibitionsAdmin', async () => {
  const { data } = await client.from('exhibitions').select('*').order('startDate', { ascending: false })
  return data || []
})
const model = ref<any>({ isPublished: true, status: 'upcoming' })
const dialog = ref(false)

async function save() {
  if (model.value.id) {
    await client.from('exhibitions').update(model.value).eq('id', model.value.id)
  } else {
    await client.from('exhibitions').insert(model.value)
  }
  dialog.value = false
  model.value = { isPublished: true, status: 'upcoming' }
  await refresh()
}
async function edit(it:any){ model.value = { ...it }; dialog.value = true }
async function del(id:number){ await client.from('exhibitions').delete().eq('id', id); await refresh() }
</script>

<template>
  <div>
    <div class="d-flex justify-space-between align-center mb-4">
      <h1 class="text-h5">Експозиції</h1>
      <v-btn color="primary" @click="dialog=true">Додати</v-btn>
    </div>
    <v-data-table :items="items" :headers="[
      { title: 'Назва', key: 'title' },
      { title: 'Статус', key: 'status' },
      { title: 'Період', key: 'startDate' }
    ]">
      <template #item.actions="{ item }">
        <v-btn size="small" @click="edit(item)">Ред.</v-btn>
        <v-btn size="small" color="error" @click="del(item.id)">Вид.</v-btn>
      </template>
    </v-data-table>

    <v-dialog v-model="dialog" max-width="640">
      <v-card class="pa-4">
        <v-text-field v-model="model.title" label="Title" />
        <v-text-field v-model="model.slug" label="Slug" />
        <v-textarea v-model="model.description" label="Description" />
        <v-select :items="['current','past','upcoming']" v-model="model.status" label="Status" />
        <v-text-field v-model="model.startDate" label="Start (YYYY-MM-DD)" />
        <v-text-field v-model="model.endDate" label="End (YYYY-MM-DD)" />
        <v-switch v-model="model.isPublished" label="Published" />
        <v-btn color="primary" @click="save">Зберегти</v-btn>
      </v-card>
    </v-dialog>
  </div>
</template>
