<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

type Row = { id:number; name:string; price:number; isActive:boolean; order?:number; [k:string]:any }

const loading = ref(true); const savingId = ref<number|null>(null); const errorMsg = ref<string|null>(null)
const items = ref<Row[]>([])

const fetchAll = async () => {
  loading.value = true; errorMsg.value = null
  const { data, error } = await supabase.from('ticket_categories').select('id,name,price,isActive,"order"').order('order',{ascending:true}).order('id',{ascending:true})
  if (error) errorMsg.value = error.message
  items.value = (data||[]) as Row[]
  loading.value = false
}
onMounted(fetchAll)

const nextOrder = () => { const arr = items.value.map(r => (typeof r['order']==='number'?r['order']:0)); return (arr.length?Math.max(...arr):0)+1 }

const addRow = async () => {
  errorMsg.value = null
  try {
    const payload = { name:'Нова категорія', price:0, isActive:true, order:nextOrder() }
    const { data, error } = await supabase.from('ticket_categories').insert(payload).select('id,name,price,isActive,"order"').single()
    if (error) throw error
    items.value.push(data as Row)
  } catch(e:any) { errorMsg.value = e?.message||'Помилка створення' }
}

const saveRow = async (row: Row) => {
  if (!row?.id) return; errorMsg.value = null; savingId.value = row.id
  try {
    const payload:any = { name:row.name?.trim()??'', price:Number(row.price??0), isActive:!!row.isActive, order:typeof row['order']==='number'?row['order']:null }
    if (!payload.name) throw new Error('Назва не може бути порожньою')
    if (payload.price < 0) throw new Error('Ціна має бути >= 0')
    const { error } = await supabase.from('ticket_categories').update(payload).eq('id', row.id)
    if (error) throw error
  } catch(e:any) { errorMsg.value = e?.message||'Помилка збереження' }
  finally { savingId.value = null }
}

const softDelete = async (row: Row) => {
  if (!row?.id) return; savingId.value = row.id
  try {
    const { error } = await supabase.from('ticket_categories').update({ isActive:false }).eq('id', row.id)
    if (error) throw error
    row.isActive = false
  } catch(e:any) { errorMsg.value = e?.message||'Помилка деактивації' }
  finally { savingId.value = null }
}

const fmt = (v:number) => new Intl.NumberFormat('uk-UA',{style:'currency',currency:'UAH'}).format(v||0)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="font-serif text-2xl font-semibold text-neutral-900">Квитки (категорії)</h1>
      <button @click="addRow" class="btn-primary text-xs">Додати</button>
    </div>

    <div v-if="errorMsg" class="alert-error mb-4">{{ errorMsg }}</div>

    <div class="bg-white border border-neutral-100 overflow-hidden">
      <table class="w-full text-sm">
        <thead>
          <tr class="border-b border-neutral-100">
            <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium">Назва</th>
            <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium w-36">Ціна (грн)</th>
            <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium w-24">Порядок</th>
            <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium w-28">Активна</th>
            <th class="px-5 py-3 w-36"></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in items" :key="row.id"
            class="border-b border-neutral-50 last:border-0"
            :class="!row.isActive ? 'opacity-50' : ''"
          >
            <td class="px-5 py-3">
              <input v-model="row.name" type="text" class="w-full bg-transparent border-b border-neutral-200 focus:border-neutral-900 outline-none py-1 text-sm text-neutral-900" />
            </td>
            <td class="px-5 py-3">
              <input v-model.number="row.price" type="number" min="0" class="w-full bg-transparent border-b border-neutral-200 focus:border-neutral-900 outline-none py-1 text-sm text-neutral-900" />
            </td>
            <td class="px-5 py-3">
              <input v-model.number="row['order']" type="number" min="0" class="w-16 bg-transparent border-b border-neutral-200 focus:border-neutral-900 outline-none py-1 text-sm text-neutral-900" />
            </td>
            <td class="px-5 py-3">
              <label class="flex items-center gap-2 cursor-pointer">
                <input type="checkbox" v-model="row.isActive" class="w-4 h-4 accent-neutral-900" />
                <span class="text-xs text-neutral-500">{{ row.isActive ? 'Так' : 'Ні' }}</span>
              </label>
            </td>
            <td class="px-5 py-3">
              <div class="flex items-center gap-2">
                <button
                  @click="saveRow(row)"
                  :disabled="savingId===row.id"
                  class="text-xs text-emerald-700 hover:text-emerald-900 underline underline-offset-2 disabled:opacity-40"
                >{{ savingId===row.id ? '...' : 'Зберегти' }}</button>
                <button
                  v-if="row.isActive"
                  @click="softDelete(row)"
                  :disabled="savingId===row.id"
                  class="text-xs text-red-500 hover:text-red-700 underline underline-offset-2 disabled:opacity-40"
                >Деактивувати</button>
              </div>
            </td>
          </tr>
          <tr v-if="!loading && !items.length">
            <td colspan="5" class="px-5 py-10 text-sm text-neutral-400 text-center italic">Немає категорій</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
