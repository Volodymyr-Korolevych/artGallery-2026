<script setup lang="ts">
definePageMeta({ middleware: 'auth' })
const client = useSupabaseClient()
const { data: items, refresh } = await useAsyncData('ticketCatsAdmin', async () => {
  const { data } = await client.from('ticket_categories').select('*').order('order')
  return data || []
})
const model = ref<any>({ isActive: true })
const dialog = ref(false)
async function save() {
  if (model.value.id) await client.from('ticket_categories').update(model.value).eq('id', model.value.id)
  else await client.from('ticket_categories').insert(model.value)
  dialog.value = false; model.value = { isActive: true }; await refresh()
}
async function edit(it:any){ model.value = { ...it }; dialog.value = true }
async function del(id:number){ await client.from('ticket_categories').delete().eq('id', id); await refresh() }
</script>

<template>
  <div>
    <div class="d-flex justify-space-between align-center mb-4">
      <h1 class="text-h5">Категорії квитків</h1>
      <v-btn color="primary" @click="dialog=true">Додати</v-btn>
    </div>
    <v-data-table :items="items" :headers="[
      { title: 'Назва', key: 'name' },
      { title: 'Ціна', key: 'price' },
      { title: 'Активна', key: 'isActive' }
    ]" />
    <v-dialog v-model="dialog" max-width="640">
      <v-card class="pa-4">
        <v-text-field v-model="model.name" label="Name" />
        <v-text-field v-model.number="model.price" label="Price" />
        <v-text-field v-model.number="model.order" label="Order" />
        <v-switch v-model="model.isActive" label="Active" />
        <v-btn color="primary" @click="save">Зберегти</v-btn>
      </v-card>
    </v-dialog>
  </div>
</template>
