<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const route = useRoute()
const supabase = useSupabaseClient()
const { uploadArtistPortrait } = useStorageUpload()

const id = Number(route.params.id)
const title = ref('Редагувати художника')
const form = ref<any>(null)
const loading = ref(true)
const saving  = ref(false)
const errorMsg = ref<string|null>(null)
const editMode = ref(true)

const fileInput = ref<HTMLInputElement|null>(null)
const pickFile = () => fileInput.value?.click()
const onFile = async (e: Event) => {
  const f = (e.target as HTMLInputElement).files?.[0]
  if (!f || !form.value?.id) return
  try {
    const url = await uploadArtistPortrait(form.value.id, f)
    form.value.imageUrl = url
    await supabase.from('artists').update({ imageUrl: url }).eq('id', form.value.id)
  } catch (e:any) {
    errorMsg.value = e?.message || 'Помилка завантаження зображення'
  }
}

const fetchOne = async () => {
  loading.value = true
  const { data, error } = await supabase
    .from('artists')
    .select('id,"fullName",description,birthYear,country,imageUrl')
    .eq('id', id).maybeSingle()
  if (error) errorMsg.value = error.message
  if (data) form.value = data
  loading.value = false
}

onMounted(fetchOne)

const save = async () => {
  if (!form.value) return
  errorMsg.value = null
  saving.value = true
  try {
    const payload:any = {
      fullName: form.value.fullName?.trim(),
      description: form.value.description || '',
      birthYear: form.value.birthYear,
      country: form.value.country || '',
      imageUrl: form.value.imageUrl || null
    }
    const { error } = await supabase.from('artists').update(payload).eq('id', id)
    if (error) throw error
  } catch (e:any) {
    errorMsg.value = e?.message || 'Помилка збереження'
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="page" v-if="form">
    <div class="head">
      <h1 class="text-h5">{{ title }}</h1>
      <div class="actions">
        <v-btn color="primary" :loading="saving" @click="save">Зберегти</v-btn>
      </div>
    </div>

    <v-card class="pa-4">
      <v-alert v-if="errorMsg" type="error" density="compact" class="mb-3">{{ errorMsg }}</v-alert>

      <v-text-field v-model="form.fullName" :readonly="!editMode" label="Ім’я" />
      <v-textarea v-model="form.description" :readonly="!editMode" label="Опис" auto-grow />
      <div class="grid-2">
        <v-text-field v-model.number="form.birthYear" :readonly="!editMode" label="Рік народження" type="number" />
        <v-text-field v-model="form.country" :readonly="!editMode" label="Країна" />
      </div>

      <div class="image mt-4">
        <div class="lbl">Портрет (фікс. висота 100px, пропорції збережені)</div>
        <div class="row">
          <v-btn variant="tonal" @click="pickFile">Оберіть файл</v-btn>
          <input ref="fileInput" type="file" accept="image/*" class="hidden" @change="onFile" />
        </div>
        <v-img
          v-if="form.imageUrl"
          :src="form.imageUrl"
          height="100"
          contain
          class="mt-2 rounded img-auto"
        />
      </div>
    </v-card>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 12px; }
.head { display:flex; align-items:center; justify-content:space-between; }
.actions { display:flex; gap:8px; }
.grid-2 { display:grid; grid-template-columns: 1fr 1fr; gap:12px; }
.hidden { display:none; }
.row { display:flex; align-items:center; gap:8px; }
.img-auto { width: auto; }
.lbl { font-size: 12px; opacity:.8; margin-bottom:4px; }
</style>
