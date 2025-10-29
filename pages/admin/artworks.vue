<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const { uploadArtworkImage } = useStorageUpload()

const arts = ref<any[]>([])
const artists = ref<any[]>([])
const exhibitions = ref<any[]>([])
const dialog = ref(false)
const edited = ref<any>({})

const canEdit = ref(false)
onMounted(async () => {
  if (!user.value) return navigateTo('/login')
  const { data } = await supabase.from('profiles').select('role').eq('id', user.value.id).maybeSingle()
  if (data?.role !== 'admin') return navigateTo('/')
  canEdit.value = true
  await fetchAll()
})

const fetchAll = async () => {
  const { data } = await supabase.from('artworks').select('*').order('id', { ascending: false })
  arts.value = data || []
  const { data: a } = await supabase.from('artists').select('id, "fullName"')
  artists.value = a || []
  const { data: e } = await supabase.from('exhibitions').select('id, title')
  exhibitions.value = e || []
}

const newItem = () => { edited.value = { title:'', artistId:null, exhibitionId:null, isPublished:true, imageUrl:'' }; dialog.value = true }
const editItem = (it:any) => { edited.value = { ...it }; dialog.value = true }

const save = async () => {
  const payload = { ...edited.value }
  if (!payload.id) {
    const { data, error } = await supabase.from('artworks').insert(payload).select('*').single()
    if (!error && data) arts.value.unshift(data)
  } else {
    const { data, error } = await supabase.from('artworks').update(payload).eq('id', payload.id).select('*').single()
    if (!error && data) {
      const idx = arts.value.findIndex(i => i.id === payload.id)
      if (idx>-1) arts.value[idx] = data
    }
  }
  dialog.value = false
}

const onImagePicked = async (files: File[]) => {
  const f = files?.[0]
  if (!f || !edited.value.id) return
  const url = await uploadArtworkImage(edited.value.id, f)
  edited.value.imageUrl = url
  await supabase.from('artworks').update({ imageUrl: url }).eq('id', edited.value.id)
}
</script>

<template>
  <div class="pa-6">
    <div class="d-flex align-center justify-space-between mb-4">
      <h1 class="text-h5">Роботи</h1>
      <v-btn color="primary" v-if="canEdit" @click="newItem">Додати</v-btn>
    </div>

    <v-data-table :items="arts" :headers="[
      { title:'ID', value:'id' },
      { title:'Назва', value:'title' },
      { title:'Художник', value:'artistId' },
      { title:'Виставка', value:'exhibitionId' },
      { title:'Опубліковано', value:'isPublished' },
      { title:'Дії', value:'actions', sortable:false }
    ]">
      <template #item.isPublished="{ item }">
        <v-chip :color="item.isPublished ? 'green' : 'grey'">{{ item.isPublished ? 'Так' : 'Ні' }}</v-chip>
      </template>
      <template #item.actions="{ item }">
        <v-btn size="small" variant="text" v-if="canEdit" @click="editItem(item)">Редагувати</v-btn>
      </template>
    </v-data-table>

    <v-dialog v-model="dialog" max-width="760">
      <v-card class="pa-4">
        <div class="text-h6 mb-3">{{ edited.id ? 'Редагувати' : 'Створити' }} роботу</div>

        <v-text-field v-model="edited.title" label="Назва" />
        <v-select v-model="edited.artistId" :items="artists" item-title="fullName" item-value="id" label="Художник" />
        <v-select v-model="edited.exhibitionId" :items="exhibitions" item-title="title" item-value="id" label="Виставка" />
        <v-switch v-model="edited.isPublished" label="Опубліковано" />

        <div>
          <div class="text-subtitle-2 mb-1">Зображення роботи</div>
          <v-file-input
            accept="image/*"
            label="Оберіть файл"
            placeholder="Файл не вибрано"
            prepend-icon="mdi-image"
            show-size
            @update:model-value="onImagePicked"
          />
          <div class="mt-2" v-if="edited.imageUrl"><img :src="edited.imageUrl" style="max-width:100%" /></div>
        </div>

        <div class="d-flex justify-end mt-4">
          <v-btn variant="text" class="mr-2" @click="dialog=false">Скасувати</v-btn>
          <v-btn color="primary" @click="save">Зберегти</v-btn>
        </div>
      </v-card>
    </v-dialog>
  </div>
</template>
