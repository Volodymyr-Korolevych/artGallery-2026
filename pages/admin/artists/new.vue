<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const form = ref({ fullName:'', description:'', birthYear: null as number|null, country:'' })
const saving = ref(false)
const errorMsg = ref<string|null>(null)

const birthYearModel = computed({
  get: () => form.value.birthYear,
  set: (val: any) => {
    if (val===''||val===null) { form.value.birthYear = null; return }
    const n = Number(String(val).replace(/\D/g,'').slice(0,4))
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
  if (!form.value.fullName.trim()) { errorMsg.value = "Вкажіть ім'я художника"; return }
  if (form.value.birthYear !== null) {
    const y = form.value.birthYear
    if (!/^\d{4}$/.test(String(y)) || y < 1000 || y > 2100) {
      errorMsg.value = 'Рік має бути 4-значний, у межах 1000–2100'; return
    }
  }
  saving.value = true
  try {
    const { data, error } = await supabase.from('artists')
      .insert({ fullName:form.value.fullName.trim(), description:form.value.description||'', birthYear:form.value.birthYear, country:form.value.country||'', imageUrl:null })
      .select('id').single()
    if (error) throw error
    await supabase.from('artists').update({ slug:`artist-${data.id}` }).eq('id', data.id)
    navigateTo('/admin/artists/'+data.id)
  } catch(e:any) { errorMsg.value = e?.message||'Помилка збереження' }
  finally { saving.value = false }
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="font-serif text-2xl font-semibold text-neutral-900">Новий художник</h1>
      <div class="flex gap-3">
        <button @click="close" class="btn-ghost text-xs">Скасувати</button>
        <button :disabled="saving" @click="save" class="btn-primary text-xs">
          {{ saving ? 'Збереження...' : 'Зберегти' }}
        </button>
      </div>
    </div>

    <div class="bg-white border border-neutral-100 p-6 space-y-5">
      <div v-if="errorMsg" class="alert-error">{{ errorMsg }}</div>

      <div>
        <label class="field-label">Повне ім'я</label>
        <input v-model="form.fullName" type="text" class="field-input" placeholder="Прізвище Ім'я По-батькові" />
      </div>

      <div>
        <label class="field-label">Опис</label>
        <textarea v-model="form.description" rows="5" class="field-input resize-none" placeholder="Біографія та творчий шлях..."></textarea>
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
          <input v-model="form.country" type="text" class="field-input" placeholder="Україна" />
        </div>
      </div>

      <div class="alert-info text-xs">
        Портрет можна додати після створення — у режимі редагування.
      </div>
    </div>
  </div>
</template>
