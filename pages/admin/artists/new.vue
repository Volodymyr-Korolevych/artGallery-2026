<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const title = ref('Додати художника')
const form = ref<{ fullName: string; description: string; birthYear: number | null; country: string }>(
  { fullName: '', description: '', birthYear: null, country: '' }
)
const saving = ref(false)
const errorMsg = ref<string|null>(null)

// Валідація року: 4 цифри, межі [1000..2100]
const yearRules = [
  (v: any) => v === null || v === '' || /^\d{4}$/.test(String(v)) || 'Введіть 4 цифри (рік)',
  (v: any) => v === null || v === '' || (+v >= 1000 && +v <= 2100) || 'Рік має бути у межах 1000–2100',
]
const birthYearModel = computed({
  get: () => form.value.birthYear,
  set: (val: any) => {
    if (val === '' || val === null) { form.value.birthYear = null; return }
    const n = Number(String(val).replace(/\D/g, '').slice(0,4))
    form.value.birthYear = isNaN(n) ? null : n
  }
})

const clampYear = () => {
  const y = form.value.birthYear
  if (y === null) return
  if (y < 1000) form.value.birthYear = 1000
  if (y > 2100) form.value.birthYear = 2100
}

const close = () => navigateTo('/admin/artists')

const save = async () => {
  errorMsg.value = null
  if (!form.value.fullName.trim()) { errorMsg.value = 'Вкажіть ім’я художника'; return }
  if (form.value.birthYear !== null) {
    const y = form.value.birthYear
    if (!/^\d{4}$/.test(String(y)) || y < 1000 || y > 2100) {
      errorMsg.value = 'Рік має бути 4-значний, у межах 1000–2100'
      return
    }
  }
  saving.value = true
  try {
    const { data, error } = await supabase
      .from('artists')
      .insert({
        fullName: form.value.fullName.trim(),
        description: form.value.description || '',
        birthYear: form.value.birthYear,
        country: form.value.country || '',
        imageUrl: null
      })
      .select('id')
      .single()
    if (error) throw error

    // технічний slug
    await supabase.from('artists')
      .update({ slug: `artist-${data.id}` })
      .eq('id', data.id)

    navigateTo('/admin/artists/' + data.id)
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

      <v-text-field v-model="form.fullName" label="Ім’я" />
      <v-textarea v-model="form.description" label="Опис" auto-grow />
      <div class="grid-2">
        <v-text-field
          :model-value="birthYearModel"
          @update:model-value="birthYearModel = $event"
          @blur="clampYear"
          label="Рік народження"
          type="text"
          inputmode="numeric"
          pattern="\\d{4}"
          :rules="yearRules"
          hint="4 цифри (1000–2100)"
          persistent-hint
        />
        <v-text-field v-model="form.country" label="Країна" />
      </div>

      <v-alert type="info" variant="tonal" density="compact" class="mt-2">
        Портрет можна додати після створення — у режимі редагування.
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
