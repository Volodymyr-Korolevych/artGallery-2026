<script setup lang="ts">
const supabase = useSupabaseClient()
const arts = ref<any[]>([])
const artists = ref<any[]>([])
const exhibitions = ref<any[]>([])
const dialog = ref(false)
const edited = ref<any>({})

const fetchAll = async () => {
  const { data } = await supabase.from('artworks').select('*').order('id', { ascending: false })
  arts.value = data || []
  const { data: a } = await supabase.from('artists').select('id, fullName')
  artists.value = a || []
  const { data: e } = await supabase.from('exhibitions').select('id, title')
  exhibitions.value = e || []
}
onMounted(fetchAll)

const newItem = () => { edited.value = { title:'', artistId:null, exhibitionId:null, isPublished:true, imageUrl:'' }; dialog.value = true }
const editItem = (it:any) => { edited.value = { ...it }; dialog.value = true }

const save = async () => {
  const payload = { ...edited.value }
  if (!payload.id) {
    const { data, error } = await supabase.from('artworks').insert(payload).select('*').single()
    if (!error) arts.value.unshift(data!)
  } else {
    const { data, error } = await supabase.from('artworks').update(payload).eq('id', payload.id).select('*').single()
    if (!error) {
      const idx = arts.value.findIndex(i => i.id === payload.id)
      if (idx>-1) arts.value[idx] = data!
    }
  }
  dialog.value = false
}

const del = async (it:any) => {
  await supabase.from('artworks').delete().eq('id', it.id)
  arts.value = arts.value.filter(x => x.id !== it.id)
}
</script>

<template>
  <div class="pa-6">
    <div class="d-flex align-center justify-space-between mb-4">
      <h1 class="text-h5">Роботи</h1>
      <v-btn color="primary" @click="newItem">Додати</v-btn>
    </div>

    <v-data-table :items="arts" :headers="[
      { title:'ID', value:'id' },
      { title:'Назва', value:'title' },
      { title:'Художник', value:'artistId' },
      { title:'Виставка', value:'exhibitionId' },
      { title:'Опубліковано', value:'isPublished' },
      { title:'Дії', value:'actions', sortable:false }
    ]">
      <template #item.artistId="{ item }">
        <span>{{ artists.find(a=>a.id===item.artistId)?.fullName || '—' }}</span>
      </template>
      <template #item.exhibitionId="{ item }">
        <span>{{ exhibitions.find(e=>e.id===item.exhibitionId)?.title || '—' }}</span>
      </template>
      <template #item.isPublished="{ item }">
        <v-chip :color="item.isPublished ? 'green' : 'grey'">{{ item.isPublished ? 'Так' : 'Ні' }}</v-chip>
      </template>
      <template #item.actions="{ item }">
        <v-btn size="small" variant="text" @click="editItem(item)">Редагувати</v-btn>
        <v-btn size="small" variant="text" color="error" @click="del(item)">Видалити</v-btn>
      </template>
    </v-data-table>

    <v-dialog v-model="dialog" max-width="700">
      <v-card class="pa-4">
        <div class="text-h6 mb-3">{{ edited.id ? 'Редагувати' : 'Створити' }} роботу</div>

        <v-text-field v-model="edited.title" label="Назва" />
        <v-select v-model="edited.artistId" :items="artists" item-title="fullName" item-value="id" label="Художник" />
        <v-select v-model="edited.exhibitionId" :items="exhibitions" item-title="title" item-value="id" label="Виставка" />
        <v-switch v-model="edited.isPublished" label="Опубліковано" />

        <div class="d-flex justify-end mt-4">
          <v-btn variant="text" class="mr-2" @click="dialog=false">Скасувати</v-btn>
          <v-btn color="primary" @click="save">Зберегти</v-btn>
        </div>
      </v-card>
    </v-dialog>
  </div>
</template>
