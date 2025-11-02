<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })

const supabase = useSupabaseClient()

const title = ref('Додати виставку')
const saving = ref(false)
const errorMsg = ref<string|null>(null)

const artists = ref<any[]>([])
const form = ref<any>({
  title: '',
  painterId: null,
  description: '',
  startDate: null, // 'YYYY-MM-DD'
  endDate: null,   // 'YYYY-MM-DD'
})

const fetchArtists = async () => {
  const { data } = await supabase.from('artists').select('id,"fullName"').order('fullName')
  artists.value = data || []
}
onMounted(fetchArtists)

const isoOrNull = (s: string | null) => s ? new Date(s).toISOString() : null

const close = () => navigateTo('/admin/exhibitions')

const save = async () => {
  errorMsg.value = null
  if (!form.value.title?.trim()) { errorMsg.value = 'Вкажіть назву виставки'; return }
  if (!form.value.painterId) { errorMsg.value = 'Оберіть художника'; return }

  saving.value = true
  try {
    const payload:any = {
      title: form.value.title.trim(),
      painterId: form.value.painterId,
      description: form.value.description || '',
      startDate: isoOrNull(form.value.startDate),
      endDate: isoOrNull(form.value.endDate),
      coverUrl: null,
      cardUrl: null,
      isPublished: false,
    }
    const { data, error } = await supabase
      .from('exhibitions')
      .insert(payload)
      .select('id')
      .single()
    if (error) throw error
    navigateTo('/admin/exhibitions/' + data.id)
  } catch (e:any) {
    errorMsg.value = e?.message || 'Помилка збереження'
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="page">
    <div class="head">
      <h1 class="text-h5">{{ title }}</h1>
      <div class="actions">
        <v-btn variant="text" @click="close">Закрити</v-btn>
        <v-btn color="primary" :loading="saving" @click="save">Зберегти</v-btn>
      </div>
    </div>

    <v-card class="pa-4">
      <v-alert v-if="errorMsg" type="error" density="compact" class="mb-3">{{ errorMsg }}</v-alert>

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
        <v-text-field v-model="form.startDate" label="Дата початку (YYYY-MM-DD)" />
        <v-text-field v-model="form.endDate" label="Дата завершення (YYYY-MM-DD)" />
      </div>

      <v-alert type="info" variant="tonal" density="compact" class="mt-2">
        Зображення (cover/card) додамо після створення на сторінці редагування.
      </v-alert>
    </v-card>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 12px; }
.head { display:flex; align-items:center; justify-content:space-between; }
.actions { display:flex; gap:8px; }
.grid-2 { display:grid; grid-template-columns: 1fr 1fr; gap: 12px; }
</style>
