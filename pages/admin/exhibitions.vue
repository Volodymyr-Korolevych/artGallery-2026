<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const { uploadCoverForExhibition, uploadCardForExhibition } = useStorageUpload()

const items = ref<any[]>([])
const artists = ref<any[]>([])
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
  const { data } = await supabase.from('exhibitions').select('*').order('createdAt', { ascending: false })
  items.value = data || []
  const { data: a } = await supabase.from('artists').select('id, "fullName"')
  artists.value = a || []
}

const fmtUA = (v: string | null) => v ? new Date(v).toLocaleDateString('uk-UA') : '—'
const toISODate = (s: string | null) => s ? new Date(s).toISOString() : null

const newItem = () => {
  edited.value = { title:'', painterId:null, isPublished:true, coverUrl:'', cardUrl:'', startDate:null, endDate:null }
  dialog.value = true
}
const editItem = (it:any) => { edited.value = { ...it }; dialog.value = true }

const save = async () => {
  const payload = { ...edited.value }
  payload.startDate = toISODate(payload.startDate)
  payload.endDate   = toISODate(payload.endDate)

  if (!payload.id) {
    const { data, error } = await supabase.from('exhibitions').insert(payload).select('*').single()
    if (!error && data) items.value.unshift(data)
  } else {
    const { data, error } = await supabase.from('exhibitions').update(payload).eq('id', payload.id).select('*').single()
    if (!error && data) {
      const idx = items.value.findIndex(i => i.id === payload.id)
      if (idx>-1) items.value[idx] = data
    }
  }
  dialog.value = false
}

const onCoverPicked = async (files: File[]) => {
  const f = files?.[0]
  if (!f || !edited.value.id) return
  const url = await uploadCoverForExhibition(edited.value.id, f)
  edited.value.coverUrl = url
  await supabase.from('exhibitions').update({ coverUrl: url }).eq('id', edited.value.id)
}
const onCardPicked = async (files: File[]) => {
  const f = files?.[0]
  if (!f || !edited.value.id) return
  const url = await uploadCardForExhibition(edited.value.id, f)
  edited.value.cardUrl = url
  await supabase.from('exhibitions').update({ cardUrl: url }).eq('id', edited.value.id)
}
</script>

<template>
  <div class="pa-6">
    <div class="d-flex align-center justify-space-between mb-4">
      <h1 class="text-h5">Виставки</h1>
      <v-btn color="primary" v-if="canEdit" @click="newItem">Додати</v-btn>
    </div>

    <v-data-table :items="items" :headers="[
      { title:'ID', value:'id' },
      { title:'Назва', value:'title' },
      { title:'Художник', value:'painterId' },
      { title:'Початок', value:'startDate' },
      { title:'Кінець', value:'endDate' },
      { title:'Опубліковано', value:'isPublished' },
      { title:'Дії', value:'actions', sortable:false }
    ]">
      <template #item.painterId="{ item }">
        <span>{{ (artists.find(a=>a.id===item.painterId)?.fullName) || '—' }}</span>
      </template>
      <template #item.startDate="{ item }">
        <span>{{ fmtUA(item.startDate) }}</span>
      </template>
      <template #item.endDate="{ item }">
        <span>{{ fmtUA(item.endDate) }}</span>
      </template>
      <template #item.isPublished="{ item }">
        <v-chip :color="item.isPublished ? 'green' : 'grey'">{{ item.isPublished ? 'Так' : 'Ні' }}</v-chip>
      </template>
      <template #item.actions="{ item }">
        <v-btn size="small" variant="text" v-if="canEdit" @click="editItem(item)">Редагувати</v-btn>
        <v-btn size="small" variant="text" v-if="canEdit" color="error" @click="() => {}" disabled>Видалити</v-btn>
      </template>
    </v-data-table>

    <v-dialog v-model="dialog" max-width="760">
      <v-card class="pa-4">
        <div class="text-h6 mb-3">{{ edited.id ? 'Редагувати' : 'Створити' }} виставку</div>

        <v-text-field v-model="edited.title" label="Назва" />
        <v-select
          v-model="edited.painterId"
          :items="artists"
          item-title="fullName"
          item-value="id"
          label="Художник"
        />
        <v-text-field v-model="edited.startDate" type="date" label="Дата початку (дд.мм.рррр)" />
        <v-text-field v-model="edited.endDate" type="date" label="Дата завершення (дд.мм.рррр)" />
        <v-switch v-model="edited.isPublished" label="Опубліковано" />

        <div class="d-flex gap-4">
          <div class="flex-1">
            <div class="text-subtitle-2 mb-1">Cover (широкий банер)</div>
            <v-file-input
              accept="image/*"
              label="Оберіть файл"
              placeholder="Файл не вибрано"
              prepend-icon="mdi-image"
              show-size
              @update:model-value="onCoverPicked"
            />
            <div class="mt-2" v-if="edited.coverUrl"><img :src="edited.coverUrl" style="max-width:100%" /></div>
          </div>
          <div class="flex-1">
            <div class="text-subtitle-2 mb-1">Card (картка у стрічці)</div>
            <v-file-input
              accept="image/*"
              label="Оберіть файл"
              placeholder="Файл не вибрано"
              prepend-icon="mdi-image"
              show-size
              @update:model-value="onCardPicked"
            />
            <div class="mt-2" v-if="edited.cardUrl"><img :src="edited.cardUrl" style="max-width:100%" /></div>
          </div>
        </div>

        <div class="d-flex justify-end mt-4">
          <v-btn variant="text" class="mr-2" @click="dialog=false">Скасувати</v-btn>
          <v-btn color="primary" @click="save">Зберегти</v-btn>
        </div>
      </v-card>
    </v-dialog>
  </div>
</template>

<style scoped>
.gap-4 { gap: 16px; }
.flex-1 { flex: 1; }
</style>
