<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
import { VueDatePicker } from '@vuepic/vue-datepicker'
import '@vuepic/vue-datepicker/dist/main.css'
import { uk } from 'date-fns/locale'

const route = useRoute()
const supabase = useSupabaseClient()
const { uploadCoverForExhibition, uploadCardForExhibition } = useStorageUpload()
const { removeExhibitionFiles } = useExhibitionStorage()
const { uploadArtwork } = useArtworkUpload()

const id = Number(route.params.id)
const pageTitle = ref('Редагувати виставку')
const artists = ref<any[]>([])
const form = ref<any>(null)
const statusItems = [{ value:'past',label:'Минула' },{ value:'current',label:'Поточна' },{ value:'upcoming',label:'Майбутня' }]

const loading = ref(true); const saving = ref(false); const editMode = ref(true); const errorMsg = ref<string|null>(null)

type Artwork = { id?:number; exhibitionId:number; artistId:number|null; title:string; year:number|null; description:string|null; slot:number; imageUrl:string|null }
const artworks = ref<Artwork[]>([])

const dialog = ref(false); const currentSlot = ref<number>(1)
const artForm = ref<Artwork>({ exhibitionId:id, artistId:null, title:'', year:null, description:'', slot:1, imageUrl:null })
const fileInput = ref<HTMLInputElement|null>(null); const filePending = ref<File|null>(null)
const editingId = ref<number|null>(null); const uploadBusy = ref(false); const uploadError = ref<string|null>(null)
const isClient = ref(false); onMounted(() => { isClient.value = true })

const previewUrl = ref<string|null>(null); let _prevObjectUrl: string|null = null
watch(() => filePending.value, (f) => {
  if (_prevObjectUrl) { URL.revokeObjectURL(_prevObjectUrl); _prevObjectUrl = null }
  if (f) { const u = URL.createObjectURL(f); _prevObjectUrl = u; previewUrl.value = u }
  else { previewUrl.value = artForm.value?.imageUrl || null }
})
watch(() => artForm.value?.imageUrl, (u) => { if (!filePending.value) previewUrl.value = u || null })
onBeforeUnmount(() => { if (_prevObjectUrl) URL.revokeObjectURL(_prevObjectUrl) })

const pickArtFile = () => fileInput.value?.click()
const onArtFile = (e: Event) => { filePending.value = (e.target as HTMLInputElement).files?.[0] || null }

const fetchArtists = async () => { const { data } = await supabase.from('artists').select('id,"fullName"').order('fullName'); artists.value = data || [] }
const fetchExhibition = async () => {
  const { data } = await supabase.from('exhibitions').select('*').eq('id', id).maybeSingle()
  if (data) { form.value = data; if (data.isPublished) { pageTitle.value = 'Переглянути виставку'; editMode.value = false } }
}
const loadArtworks = async () => { const { data } = await supabase.from('artworks').select('*').eq('exhibitionId', id).order('slot'); artworks.value = data || [] }

onMounted(async () => { loading.value = true; await Promise.all([fetchArtists(), fetchExhibition(), loadArtworks()]); loading.value = false })

const enableEdit = () => { editMode.value = true; pageTitle.value = 'Редагувати виставку' }
const close = () => navigateTo('/admin/exhibitions')

const saveExhibition = async () => {
  if (!form.value) return; errorMsg.value = null; saving.value = true
  try {
    const payload: any = { ...form.value }
    payload.startDate = form.value.startDate ? new Date(form.value.startDate).toISOString() : null
    payload.endDate = form.value.endDate ? new Date(form.value.endDate).toISOString() : null
    const { data, error } = await supabase.from('exhibitions').update(payload).eq('id', id).select('*').single()
    if (error) throw error
    if (data?.isPublished) { pageTitle.value = 'Переглянути виставку'; editMode.value = false }
  } catch(e:any) { errorMsg.value = e?.message||'Помилка збереження' }
  finally { saving.value = false }
}

const delExhibition = async () => {
  if (!confirm('Видалити виставку?')) return
  await removeExhibitionFiles(id)
  await supabase.from('exhibitions').delete().eq('id', id)
  navigateTo('/admin/exhibitions')
}

const coverInput = ref<HTMLInputElement|null>(null); const cardInput = ref<HTMLInputElement|null>(null)
const pickCover = () => coverInput.value?.click(); const pickCard = () => cardInput.value?.click()
const onCoverChange = async (e: Event) => { const f = (e.target as HTMLInputElement).files?.[0]; if (!f||!form.value?.id) return; const url = await uploadCoverForExhibition(form.value.id, f); form.value.coverUrl = url; await supabase.from('exhibitions').update({ coverUrl: url }).eq('id', form.value.id) }
const onCardChange = async (e: Event) => { const f = (e.target as HTMLInputElement).files?.[0]; if (!f||!form.value?.id) return; const url = await uploadCardForExhibition(form.value.id, f); form.value.cardUrl = url; await supabase.from('exhibitions').update({ cardUrl: url }).eq('id', form.value.id) }

const openSlotDialog = (slot: number) => {
  currentSlot.value = slot
  const existing = artworks.value.find(a => a.slot === slot)
  if (existing) { editingId.value = existing.id!; artForm.value = { ...existing } }
  else { editingId.value = null; artForm.value = { exhibitionId:id, artistId:form.value?.painterId||null, title:'', year:null, description:'', slot, imageUrl:null } }
  filePending.value = null; uploadError.value = null; previewUrl.value = artForm.value.imageUrl || null; dialog.value = true
}

const saveArtwork = async () => {
  uploadError.value = null
  try {
    if (!artForm.value.title?.trim()) throw new Error('Вкажіть назву роботи')
    uploadBusy.value = true
    if (filePending.value) { const url = await uploadArtwork(id, artForm.value.slot, filePending.value); artForm.value.imageUrl = url }
    if (editingId.value) { await supabase.from('artworks').update({ title:artForm.value.title.trim(), year:artForm.value.year, description:artForm.value.description||'', imageUrl:artForm.value.imageUrl, artistId:form.value?.painterId||null }).eq('id', editingId.value) }
    else { await supabase.from('artworks').insert({ exhibitionId:id, artistId:form.value?.painterId||null, title:artForm.value.title.trim(), year:artForm.value.year, description:artForm.value.description||'', slot:artForm.value.slot, imageUrl:artForm.value.imageUrl }) }
    dialog.value = false; await loadArtworks()
  } catch(e:any) { uploadError.value = e?.message||'Помилка збереження' }
  finally { uploadBusy.value = false }
}
</script>

<template>
  <div v-if="!loading && form" class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <h1 class="font-serif text-2xl font-semibold text-neutral-900">{{ pageTitle }}</h1>
      <div class="flex gap-3">
        <button @click="close" class="btn-ghost text-xs">Закрити</button>
        <button v-if="!editMode" @click="enableEdit" class="btn-outline text-xs">Редагувати</button>
        <button v-if="editMode" @click="delExhibition" class="btn-outline text-xs border-red-300 text-red-600 hover:bg-red-600 hover:border-red-600 hover:text-white">Видалити</button>
        <button v-if="editMode" :disabled="saving" @click="saveExhibition" class="btn-primary text-xs">
          {{ saving ? 'Збереження...' : 'Зберегти' }}
        </button>
      </div>
    </div>

    <div class="bg-white border border-neutral-100 p-6 space-y-5">
      <div v-if="errorMsg" class="alert-error">{{ errorMsg }}</div>

      <!-- Status + Published -->
      <div class="flex items-center gap-6 flex-wrap">
        <div class="w-48">
          <label class="field-label">Статус</label>
          <select v-model="form.status" :disabled="!editMode" class="field-input">
            <option v-for="s in statusItems" :key="s.value" :value="s.value">{{ s.label }}</option>
          </select>
        </div>
        <label v-if="editMode" class="flex items-center gap-2 cursor-pointer mt-4">
          <input type="checkbox" v-model="form.isPublished" class="w-4 h-4 accent-neutral-900" />
          <span class="text-sm text-neutral-700">Опубліковано</span>
        </label>
      </div>

      <div>
        <label class="field-label">Назва</label>
        <input v-model="form.title" :readonly="!editMode" type="text" class="field-input" />
      </div>

      <div>
        <label class="field-label">Художник</label>
        <select v-model="form.painterId" :disabled="!editMode" class="field-input">
          <option :value="null">— Оберіть —</option>
          <option v-for="a in artists" :key="a.id" :value="a.id">{{ a.fullName }}</option>
        </select>
      </div>

      <div>
        <label class="field-label">Короткий опис</label>
        <textarea v-model="form.short" :readonly="!editMode" rows="2" class="field-input resize-none"></textarea>
      </div>

      <div>
        <label class="field-label">Повний опис</label>
        <textarea v-model="form.description" :readonly="!editMode" rows="5" class="field-input resize-none"></textarea>
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

      <!-- Images -->
      <div class="grid grid-cols-2 gap-6">
        <div>
          <label class="field-label">Cover (обкладинка)</label>
          <button v-if="editMode" @click="pickCover" class="btn-outline text-xs mt-1">Оберіть файл</button>
          <input ref="coverInput" type="file" accept="image/*" class="hidden" @change="onCoverChange" />
          <img v-if="form.coverUrl" :src="form.coverUrl" class="mt-2 h-24 object-contain" />
        </div>
        <div>
          <label class="field-label">Card (картка)</label>
          <button v-if="editMode" @click="pickCard" class="btn-outline text-xs mt-1">Оберіть файл</button>
          <input ref="cardInput" type="file" accept="image/*" class="hidden" @change="onCardChange" />
          <img v-if="form.cardUrl" :src="form.cardUrl" class="mt-2 h-24 object-contain" />
        </div>
      </div>

      <!-- Artworks slots -->
      <div class="mt-2">
        <div class="text-xs tracking-widest uppercase text-neutral-500 font-medium mb-3">Роботи (макс. 6) — клікніть по слоту</div>
        <div class="grid grid-cols-3 lg:grid-cols-6 gap-3">
          <div
            v-for="i in 6" :key="i"
            @click="openSlotDialog(i)"
            class="border border-dashed border-neutral-200 hover:border-neutral-400 p-2 cursor-pointer transition-colors text-center"
          >
            <img v-if="artworks.find(a=>a.slot===i)?.imageUrl" :src="artworks.find(a=>a.slot===i)?.imageUrl" class="h-20 w-full object-contain mb-1" />
            <div v-else class="h-20 flex items-center justify-center text-neutral-300">—</div>
            <div class="text-xs text-neutral-500 truncate">{{ artworks.find(a=>a.slot===i)?.title || ('Робота '+i) }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Artwork Dialog -->
    <div v-if="dialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="dialog = false">
      <div class="bg-white w-full max-w-md p-6 space-y-4">
        <div class="flex items-center justify-between">
          <h2 class="font-serif text-lg font-semibold">Робота {{ currentSlot }}</h2>
          <button @click="dialog = false" class="text-neutral-400 hover:text-neutral-900">✕</button>
        </div>

        <div v-if="uploadError" class="alert-error">{{ uploadError }}</div>

        <div>
          <label class="field-label">Назва роботи</label>
          <input v-model="artForm.title" type="text" class="field-input" />
        </div>
        <div>
          <label class="field-label">Рік</label>
          <input v-model.number="artForm.year" type="number" class="field-input" />
        </div>
        <div>
          <label class="field-label">Опис</label>
          <textarea v-model="artForm.description" rows="3" class="field-input resize-none"></textarea>
        </div>

        <div>
          <button @click="pickArtFile" class="btn-outline text-xs">Оберіть зображення</button>
          <input ref="fileInput" type="file" accept="image/*" class="hidden" @change="onArtFile" />
        </div>

        <client-only v-if="isClient">
          <img v-if="previewUrl" :src="previewUrl" class="h-28 object-contain mt-1" />
        </client-only>

        <div class="flex justify-end gap-3 pt-2">
          <button @click="dialog = false" class="btn-ghost text-xs">Скасувати</button>
          <button :disabled="uploadBusy" @click="saveArtwork" class="btn-primary text-xs">
            {{ uploadBusy ? 'Збереження...' : 'Зберегти' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
