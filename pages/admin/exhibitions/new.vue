<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()
const { slugify } = useSlug()

const title = ref('Додати виставку')
const artists = ref<any[]>([])
const form = ref<{
  title: string
  painterId: number|null
  description: string
  startDate: string | null   // YYYY-MM-DD
  endDate: string | null     // YYYY-MM-DD
}>({
  title: '',
  painterId: null,
  description: '',
  startDate: null,
  endDate: null
})

const loading = ref(false)
const errorMsg = ref<string | null>(null)
const showStart = ref(false)
const showEnd = ref(false)

const fetchArtists = async () => {
  const { data, error } = await supabase.from('artists').select('id,"fullName"').order('fullName')
  if (!error) artists.value = data || []
}
onMounted(fetchArtists)

const save = async () => {
  errorMsg.value = null
  if (!form.value.title?.trim()) { errorMsg.value = 'Вкажіть назву виставки'; return }
  if (!form.value.painterId)     { errorMsg.value = 'Оберіть художника'; return }

  loading.value = true
  try {
    // 1) побудувати базовий slug
    let base = slugify(form.value.title)
    if (!base) base = 'exhibition'
    let candidate = base
    // 2) перевірити колізії і знайти вільний слуг
    let n = 1
    while (true) {
      const { data: exists, error } = await supabase
        .from('exhibitions')
        .select('id')
        .eq('slug', candidate)
        .limit(1)
      if (error) throw error
      if (!exists || exists.length === 0) break
      n += 1
      candidate = `${base}-${n}`
      if (n > 9999) throw new Error('Не вдалося згенерувати унікальний slug')
    }

    const payload:any = {
      title: form.value.title.trim(),
      slug: candidate,
      painterId: form.value.painterId,
      description: form.value.description || '',
      startDate: form.value.startDate ? new Date(form.value.startDate).toISOString() : null,
      endDate:   form.value.endDate ? new Date(form.value.endDate).toISOString() : null,
      isPublished: false,
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

      <div class="grid-2">
        <div>
          <v-text-field
            v-model="form.startDate"
            label="Дата початку"
            readonly
            :value="form.startDate"
            @click="showStart = true"
          />
          <v-dialog v-model="showStart" max-width="360">
            <v-card>
              <v-date-picker v-model="form.startDate" locale="uk" hide-actions />
              <v-card-actions class="justify-end">
                <v-btn variant="text" @click="showStart=false">OK</v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </div>

        <div>
          <v-text-field
            v-model="form.endDate"
            label="Дата завершення"
            readonly
            :value="form.endDate"
            @click="showEnd = true"
          />
          <v-dialog v-model="showEnd" max-width="360">
            <v-card>
              <v-date-picker v-model="form.endDate" locale="uk" hide-actions />
              <v-card-actions class="justify-end">
                <v-btn variant="text" @click="showEnd=false">OK</v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </div>
      </div>

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
