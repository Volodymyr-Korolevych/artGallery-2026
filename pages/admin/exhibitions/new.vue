<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
import { VueDatePicker } from '@vuepic/vue-datepicker'
import '@vuepic/vue-datepicker/dist/main.css'
import { uk } from 'date-fns/locale'

const supabase = useSupabaseClient()
const saving = ref(false)
const errorMsg = ref<string|null>(null)
const toSlug = (s:string) => s.toLowerCase().trim().replace(/[^a-zа-яіїє0-9]+/gi,'-').replace(/^-+|-+$/g,'')

const artists = ref<any[]>([])
const form = ref<any>({ title:'', painterId:null, short:'', description:'', startDate:null, endDate:null })

const fetchArtists = async () => {
  const { data } = await supabase.from('artists').select('id,"fullName"').order('fullName')
  artists.value = data || []
}
onMounted(fetchArtists)

const toISOorNull = (s:string|null) => s ? new Date(s).toISOString() : null
const close = () => navigateTo('/admin/exhibitions')

const save = async () => {
  errorMsg.value = null
  if (!form.value.title?.trim()) { errorMsg.value = 'Вкажіть назву виставки'; return }
  if (!form.value.painterId) { errorMsg.value = 'Оберіть художника'; return }
  saving.value = true
  try {
    const payload:any = { title:form.value.title.trim(), slug:toSlug(form.value.title), painterId:form.value.painterId, short:form.value.short||null, description:form.value.description||'', startDate:toISOorNull(form.value.startDate), endDate:toISOorNull(form.value.endDate), coverUrl:null, cardUrl:null, isPublished:false, status:'upcoming' }
    const { data, error } = await supabase.from('exhibitions').insert(payload).select('id').single()
    if (error) throw error
    navigateTo('/admin/exhibitions/'+data.id)
  } catch(e:any) { errorMsg.value = e?.message||'Помилка збереження' }
  finally { saving.value = false }
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="font-serif text-2xl font-semibold text-neutral-900">Нова виставка</h1>
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
        <label class="field-label">Назва</label>
        <input v-model="form.title" type="text" class="field-input" placeholder="Назва виставки" />
      </div>

      <div>
        <label class="field-label">Художник</label>
        <select v-model="form.painterId" class="field-input">
          <option :value="null">— Оберіть художника —</option>
          <option v-for="a in artists" :key="a.id" :value="a.id">{{ a.fullName }}</option>
        </select>
      </div>

      <div>
        <label class="field-label">Короткий опис</label>
        <textarea v-model="form.short" rows="2" class="field-input resize-none" placeholder="1 абзац"></textarea>
      </div>

      <div>
        <label class="field-label">Повний опис</label>
        <textarea v-model="form.description" rows="5" class="field-input resize-none"></textarea>
      </div>

      <div class="grid grid-cols-2 gap-6">
        <div>
          <label class="field-label">Дата початку</label>
          <VueDatePicker v-model="form.startDate" :locale="uk" auto-apply :enable-time-picker="false" />
        </div>
        <div>
          <label class="field-label">Дата завершення</label>
          <VueDatePicker v-model="form.endDate" :locale="uk" auto-apply :enable-time-picker="false" />
        </div>
      </div>

      <div class="alert-info text-xs">
        Зображення (cover/card) можна додати після створення — на сторінці редагування.
      </div>
    </div>
  </div>
</template>
