<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()
const { uploadCoverForExhibition, uploadCardForExhibition } = useStorageUpload()

const title = ref('Додати виставку')
const artists = ref<any[]>([])
const form = ref<any>({
  title: '',
  painterId: null,
  description: '',
  startDate: null,
  endDate: null,
  isPublished: false,
  coverUrl: '',
  cardUrl: ''
})
const loading = ref(false)

const fetchArtists = async () => {
  const { data } = await supabase.from('artists').select('id,"fullName"').order('fullName')
  artists.value = data || []
}
onMounted(fetchArtists)

const toISO = (s: string | null) => s ? new Date(s).toISOString() : null

const save = async () => {
  loading.value = true
  const payload = { ...form.value }
  payload.startDate = toISO(payload.startDate)
  payload.endDate   = toISO(payload.endDate)
  const { data, error } = await supabase.from('exhibitions').insert(payload).select('*').single()
  loading.value = false
  if (!error && data) navigateTo('/admin/exhibitions/' + data.id)
}

const coverInput = ref<HTMLInputElement|null>(null)
const cardInput  = ref<HTMLInputElement|null>(null)
const pickCover = () => coverInput.value?.click()
const pickCard  = () => cardInput.value?.click()

const onCoverChange = (e: Event) => {
  const f = (e.target as HTMLInputElement).files?.[0]
  if (!f) return
  form.value.coverUrl = URL.createObjectURL(f)
}
const onCardChange = (e: Event) => {
  const f = (e.target as HTMLInputElement).files?.[0]
  if (!f) return
  form.value.cardUrl = URL.createObjectURL(f)
}
</script>

<template>
  <div class="page">
    <div class="head">
      <h1 class="text-h5">{{ title }}</h1>
      <div class="actions">
        <v-btn color="primary" :loading="loading" @click="save">Зберегти</v-btn>
      </div>
    </div>

    <v-card class="pa-4">
      <v-text-field v-model="form.title" label="Назва" />
      <v-select
        v-model="form.painterId"
        :items="artists"
        item-title="fullName"
        item-value="id"
        label="Художник"
      />
      <v-textarea v-model="form.description" label="Опис виставки" auto-grow />

      <div class="grid-2">
        <v-text-field v-model="form.startDate" type="date" label="Дата початку" />
        <v-text-field v-model="form.endDate" type="date" label="Дата завершення" />
      </div>

      <v-switch v-model="form.isPublished" label="Опубліковано" />

      <div class="images">
        <div>
          <div class="lbl">Cover (100px)</div>
          <v-btn variant="tonal" @click="pickCover">Оберіть файл</v-btn>
          <input ref="coverInput" type="file" accept="image/*" class="hidden" @change="onCoverChange" />
          <v-img v-if="form.coverUrl" :src="form.coverUrl" height="100" cover class="mt-2 rounded-lg" />
        </div>
        <div>
          <div class="lbl">Card (100px)</div>
          <v-btn variant="tonal" @click="pickCard">Оберіть файл</v-btn>
          <input ref="cardInput" type="file" accept="image/*" class="hidden" @change="onCardChange" />
          <v-img v-if="form.cardUrl" :src="form.cardUrl" height="100" cover class="mt-2 rounded-lg" />
        </div>
      </div>

      <div class="artworks">
        <div class="subhead">Роботи (макс. 6)</div>
        <div class="slots">
          <div v-for="i in 6" :key="i" class="slot">—</div>
        </div>
      </div>
    </v-card>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 16px; }
.head { display:flex; align-items:center; justify-content:space-between; }
.actions { display:flex; gap:8px; }
.grid-2 { display:grid; grid-template-columns: 1fr 1fr; gap:16px; }
.images { display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-top:8px; }
.lbl { font-size: 12px; opacity:.8; margin-bottom:4px; }
.hidden { display:none; }
.artworks { margin-top: 16px; }
.subhead { font-weight:600; margin-bottom: 8px; }
.slots { display:grid; grid-template-columns: repeat(6, 1fr); gap: 8px; }
.slot { height: 80px; border:1px dashed rgba(0,0,0,.2); border-radius:8px; display:flex; align-items:center; justify-content:center;}
@media (max-width: 1200px) { .slots { grid-template-columns: repeat(3, 1fr); } }
</style>
