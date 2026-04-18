<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const route = useRoute()
const supabase = useSupabaseClient()
const { uploadArtistPortrait } = useStorageUpload()

const id = Number(route.params.id)
const form = ref<any>(null)
const loading = ref(true)
const saving  = ref(false)
const errorMsg = ref<string|null>(null)

const close = () => navigateTo('/admin/artists')

const birthYearModel = computed({
  get: () => form.value?.birthYear ?? null,
  set: (val: any) => {
    if (!form.value) return
    if (val===''||val===null) { form.value.birthYear = null; return }
    const n = Number(String(val).replace(/\D/g,'').slice(0,4))
    form.value.birthYear = isNaN(n) ? null : n
  }
})
const clampYear = () => {
  if (!form.value) return
  const y = form.value.birthYear
  if (y === null) return
  if (y < 1000) form.value.birthYear = 1000
  if (y > 2100) form.value.birthYear = 2100
}

const fileInput = ref<HTMLInputElement|null>(null)
const pickFile = () => fileInput.value?.click()
const onFile = async (e: Event) => {
  const f = (e.target as HTMLInputElement).files?.[0]
  if (!f || !form.value?.id) return
  try {
    const url = await uploadArtistPortrait(form.value.id, f)
    form.value.imageUrl = url
    await supabase.from('artists').update({ imageUrl: url }).eq('id', form.value.id)
  } catch(e:any) { errorMsg.value = e?.message||'Помилка завантаження зображення' }
}

const fetchOne = async () => {
  loading.value = true
  const { data, error } = await supabase.from('artists').select('id,"fullName",description,birthYear,country,imageUrl').eq('id', id).maybeSingle()
  if (error) errorMsg.value = error.message
  if (data) form.value = data
  loading.value = false
}
onMounted(fetchOne)

const save = async () => {
  if (!form.value) return
  errorMsg.value = null
  if (form.value.birthYear !== null) {
    const y = form.value.birthYear
    if (!/^\d{4}$/.test(String(y)) || y < 1000 || y > 2100) {
      errorMsg.value = 'Рік має бути 4-значний, у межах 1000–2100'; return
    }
  }
  saving.value = true
  try {
    const payload:any = { fullName:form.value.fullName?.trim(), description:form.value.description||'', birthYear:form.value.birthYear, country:form.value.country||'', imageUrl:form.value.imageUrl||null }
    const { error } = await supabase.from('artists').update(payload).eq('id', id)
    if (error) throw error
  } catch(e:any) { errorMsg.value = e?.message||'Помилка збереження' }
  finally { saving.value = false }
}
</script>

<template>
  <div v-if="!loading && form">
    <div class="flex items-center justify-between mb-6">
      <h1 class="font-serif text-2xl font-semibold text-neutral-900">Редагувати художника</h1>
      <div class="flex gap-3">
        <button @click="close" class="btn-ghost text-xs">Закрити</button>
        <button :disabled="saving" @click="save" class="btn-primary text-xs">
          {{ saving ? 'Збереження...' : 'Зберегти' }}
        </button>
      </div>
    </div>

    <div class="bg-white border border-neutral-100 p-6 space-y-5">
      <div v-if="errorMsg" class="alert-error">{{ errorMsg }}</div>

      <div>
        <label class="field-label">Повне ім'я</label>
        <input v-model="form.fullName" type="text" class="field-input" />
      </div>

      <div>
        <label class="field-label">Опис</label>
        <textarea v-model="form.description" rows="5" class="field-input resize-none"></textarea>
      </div>

      <div class="grid grid-cols-2 gap-6">
        <div>
          <label class="field-label">Рік народження</label>
          <input
            :value="birthYearModel"
            @input="e => birthYearModel = (e.target as HTMLInputElement).value"
            @blur="clampYear"
            type="text" inputmode="numeric" maxlength="4"
            class="field-input" placeholder="1970"
          />
          <div class="text-xs text-neutral-400 mt-1">4 цифри (1000–2100)</div>
        </div>
        <div>
          <label class="field-label">Країна</label>
          <input v-model="form.country" type="text" class="field-input" />
        </div>
      </div>

      <!-- Portrait -->
      <div>
        <label class="field-label">Портрет</label>
        <div class="flex items-start gap-4 mt-2">
          <div>
            <button @click="pickFile" class="btn-outline text-xs">Оберіть файл</button>
            <input ref="fileInput" type="file" accept="image/*" class="hidden" @change="onFile" />
          </div>
          <img v-if="form.imageUrl" :src="form.imageUrl" class="h-24 object-contain border border-neutral-100" />
          <div v-else class="h-24 w-24 bg-neutral-100 flex items-center justify-center font-serif text-3xl text-neutral-300">
            {{ form.fullName?.[0] }}
          </div>
        </div>
      </div>
    </div>
  </div>

  <div v-if="loading" class="animate-pulse space-y-4">
    <div class="h-8 bg-neutral-200 rounded w-1/3"></div>
    <div class="h-64 bg-neutral-100 rounded"></div>
  </div>
</template>
