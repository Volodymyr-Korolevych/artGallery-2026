<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const title = ref('Додати художника')
const form = ref<{ fullName: string; description: string; birthYear: number|null; country: string }>(
  { fullName: '', description: '', birthYear: null, country: '' }
)
const saving = ref(false)
const errorMsg = ref<string|null>(null)

const save = async () => {
  errorMsg.value = null
  if (!form.value.fullName.trim()) { errorMsg.value = 'Вкажіть ім’я художника'; return }
  saving.value = true
  try {
    const payload:any = {
      fullName: form.value.fullName.trim(),
      description: form.value.description || '',
      birthYear: form.value.birthYear,
      country: form.value.country || '',
      imageUrl: null
    }
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

    // технічний унікальний slug на основі id
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
      <v-btn color="primary" :loading="saving" @click="save">Зберегти</v-btn>
    </div>

    <v-card class="pa-4">
      <v-alert v-if="errorMsg" type="error" density="compact" class="mb-3">{{ errorMsg }}</v-alert>

      <v-text-field v-model="form.fullName" label="Ім’я" />
      <v-textarea v-model="form.description" label="Опис" auto-grow />
      <div class="grid-2">
        <v-text-field v-model.number="form.birthYear" label="Рік народження" type="number" />
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
.grid-2 { display:grid; grid-template-columns: 1fr 1fr; gap: 12px; }
</style>
