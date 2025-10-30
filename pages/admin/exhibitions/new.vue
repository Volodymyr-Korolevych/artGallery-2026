<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const title = ref('Додати виставку')
const artists = ref<any[]>([])
const form = ref<{
  title: string
  painterId: number|null
  description: string
  startDate: Date|null
  endDate: Date|null
}>({
  title: '',
  painterId: null,
  description: '',
  startDate: null,
  endDate: null
})

const loading = ref(false)
const errorMsg = ref<string | null>(null)

const fetchArtists = async () => {
  const { data, error } = await supabase.from('artists').select('id,"fullName"').order('fullName')
  if (!error) artists.value = data || []
}
onMounted(fetchArtists)

const toISO = (d: Date | null) => d ? new Date(d).toISOString() : null

const save = async () => {
  errorMsg.value = null
  if (!form.value.title?.trim()) { errorMsg.value = 'Вкажіть назву виставки'; return }
  if (!form.value.painterId)     { errorMsg.value = 'Оберіть художника'; return }

  loading.value = true
  try {
    const payload:any = {
      title: form.value.title.trim(),
      painterId: form.value.painterId,
      description: form.value.description || '',
      startDate: toISO(form.value.startDate),
      endDate:   toISO(form.value.endDate),
      isPublished: false,       // нові — як чернетка
      coverUrl: null,
      cardUrl:  null
    }
    const { data, error } = await supabase
      .from('exhibitions')
      .insert(payload)
      .select('*')
      .single()
    if (error) throw error
    if (data?.id) navigateTo('/admin/exhibitions/' + data.id)
  } catch (e:any) {
    errorMsg.value = e?.message || 'Помилка збереження'
  } finally {
    loading.value = false
  }
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
      <v-alert v-if="errorMsg" type="error" class="mb-4" density="compact">{{ errorMsg }}</v-alert>

      <v-text-field v-model="form.title" label="Назва" />
      <v-select
        v-model="form.painterId"
        :items="artists"
        item-title="fullName"
        item-value="id"
        label="Художник"
      />
      <v-textarea v-model="form.description" label="Опис виставки" auto-grow />

      <VLocaleProvider locale="uk">
        <div class="grid-2">
          <v-date-input v-model="form.startDate" label="Дата початку" prepend-icon="mdi-calendar" />
          <v-date-input v-model="form.endDate" label="Дата завершення" prepend-icon="mdi-calendar" />
        </div>
      </VLocaleProvider>

      <!-- Зображення/Опублікувати прибрано на етапі створення -->
      <v-alert type="info" variant="tonal" class="mt-4" density="compact">
        Зображення (cover/card) і публікацію можна додати після створення — у режимі редагування.
      </v-alert>
    </v-card>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 16px; }
.head { display:flex; align-items:center; justify-content:space-between; }
.actions { display:flex; gap:8px; }
.grid-2 { display:grid; grid-template-columns: 1fr 1fr; gap:16px; }
</style>
