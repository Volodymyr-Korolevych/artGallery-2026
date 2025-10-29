<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const { uploadArtistPortrait } = useStorageUpload()

const items = ref<any[]>([])
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
  const { data } = await supabase.from('artists').select('*').order('id', { ascending: false })
  items.value = data || []
}

const newItem = () => { edited.value = { fullName:'', portraitUrl:'', isPublished:true }; dialog.value = true }
const editItem = (it:any) => { edited.value = { ...it }; dialog.value = true }

const save = async () => {
  const payload = { ...edited.value }
  if (!payload.id) {
    const { data, error } = await supabase.from('artists').insert(payload).select('*').single()
    if (!error && data) items.value.unshift(data)
  } else {
    const { data, error } = await supabase.from('artists').update(payload).eq('id', payload.id).select('*').single()
    if (!error && data) {
      const idx = items.value.findIndex(i => i.id === payload.id)
      if (idx>-1) items.value[idx] = data
    }
  }
  dialog.value = false
}

const pickPortrait = async (e:Event) => {
  const f = (e.target as HTMLInputElement).files?.[0]
  if (!f || !edited.value.id) return
  const url = await uploadArtistPortrait(edited.value.id, f)
  edited.value.portraitUrl = url
  await supabase.from('artists').update({ portraitUrl: url }).eq('id', edited.value.id)
}
</script>

<template>
  <div class="pa-6">
    <div class="d-flex align-center justify-space-between mb-4">
      <h1 class="text-h5">Художники</h1>
      <v-btn color="primary" v-if="canEdit" @click="newItem">Додати</v-btn>
    </div>

    <v-data-table :items="items" :headers="[
      { title:'ID', value:'id' },
      { title:'Імʼя', value:'fullName' },
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

    <v-dialog v-model="dialog" max-width="700">
      <v-card class="pa-4">
        <div class="text-h6 mb-3">{{ edited.id ? 'Редагувати' : 'Створити' }} художника</div>

        <v-text-field v-model="edited.fullName" label="Імʼя та прізвище" />
        <v-switch v-model="edited.isPublished" label="Опубліковано" />

        <div>
          <div class="text-subtitle-2 mb-1">Портрет</div>
          <input type="file" accept="image/*" @change="pickPortrait" :disabled="!edited.id" />
          <div class="mt-2" v-if="edited.portraitUrl"><img :src="edited.portraitUrl" style="max-width:100%" /></div>
        </div>

        <div class="d-flex justify-end mt-4">
          <v-btn variant="text" class="mr-2" @click="dialog=false">Скасувати</v-btn>
          <v-btn color="primary" @click="save">Зберегти</v-btn>
        </div>
      </v-card>
    </v-dialog>
  </div>
</template>
