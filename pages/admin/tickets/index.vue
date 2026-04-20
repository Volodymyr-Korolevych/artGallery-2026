<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

type Row = { id: number; name: string; price: number; isActive: boolean; order?: number;[k: string]: any }

const loading = ref(true)
const savingId = ref<number | null>(null)
const errorMsg = ref<string | null>(null)
const items = ref<Row[]>([])

const fetchAll = async () => {
  loading.value = true
  errorMsg.value = null
  const { data, error } = await supabase
    .from('ticket_categories')
    .select('id,name,price,isActive,"order"')
    .order('order', { ascending: true })
    .order('id', { ascending: true })

  if (error) errorMsg.value = error.message
  items.value = (data || []) as Row[]
  loading.value = false
}
onMounted(fetchAll)

const nextOrder = () => {
  const arr = items.value.map(r => (typeof r['order'] === 'number' ? r['order'] : 0))
  return (arr.length ? Math.max(...arr) : 0) + 1
}

const addRow = async () => {
  errorMsg.value = null
  try {
    const payload = {
      name: 'Нова категорія',
      price: 0,
      isActive: true,
      order: nextOrder()
    }

    const { data, error } = await supabase
      .from('ticket_categories')
      .insert(payload)
      .select('id,name,price,isActive,"order"')
      .single()

    if (error) throw error
    items.value.push(data as Row)
  } catch (e: any) {
    errorMsg.value = e?.message || 'Помилка створення'
  }
}

const saveRow = async (row: Row) => {
  if (!row?.id) return
  errorMsg.value = null
  savingId.value = row.id

  try {
    const payload: any = {
      name: row.name?.trim() ?? '',
      price: Number(row.price ?? 0),
      isActive: !!row.isActive,
      order: typeof row['order'] === 'number' ? row['order'] : null
    }

    if (!payload.name) throw new Error('Назва не може бути порожньою')
    if (payload.price < 0) throw new Error('Ціна має бути >= 0')

    const { error } = await supabase
      .from('ticket_categories')
      .update(payload)
      .eq('id', row.id)

    if (error) throw error
  } catch (e: any) {
    errorMsg.value = e?.message || 'Помилка збереження'
  } finally {
    savingId.value = null
  }
}

const deleteRow = async (row: Row) => {
  if (!row?.id) return
  errorMsg.value = null

  if (!confirm(`Видалити категорію «${row.name}»?`)) return

  savingId.value = row.id
  try {
    const { error } = await supabase
      .from('ticket_categories')
      .delete()
      .eq('id', row.id)

    if (error) throw error

    items.value = items.value.filter(r => r.id !== row.id)
  } catch (e: any) {
    errorMsg.value = e?.message || 'Помилка видалення'
  } finally {
    savingId.value = null
  }
}

const fmt = (v: number) =>
  new Intl.NumberFormat('uk-UA', { style: 'currency', currency: 'UAH' }).format(v || 0)
</script>

<template>
  <div>
    <div class="mb-5 flex items-center justify-between">
      <h1 class="font-serif text-2xl font-semibold text-neutral-900">
        Квитки (категорії)
      </h1>
      <button @click="addRow" class="btn-primary text-xs">
        Додати
      </button>
    </div>

    <div v-if="errorMsg" class="alert-error mb-3">
      {{ errorMsg }}
    </div>

    <div class="overflow-hidden border border-neutral-100 bg-white">
      <table class="w-full text-xs">
        <thead>
          <tr class="border-b border-neutral-100">
            <th class="px-3 py-2 text-left text-[11px] font-medium uppercase tracking-widest text-neutral-400">
              Назва
            </th>
            <th class="w-32 px-3 py-2 text-left text-[11px] font-medium uppercase tracking-widest text-neutral-400">
              Ціна
            </th>
            <th class="w-20 px-3 py-2 text-left text-[11px] font-medium uppercase tracking-widest text-neutral-400">
              Порядок
            </th>
            <th class="w-24 px-3 py-2 text-left text-[11px] font-medium uppercase tracking-widest text-neutral-400">
              Активна
            </th>
            <th class="w-12 px-3 py-2"></th>
          </tr>
        </thead>

        <tbody>
          <tr v-for="row in items" :key="row.id" class="border-b border-neutral-50 last:border-0"
            :class="!row.isActive ? 'opacity-50' : ''">
            <td class="px-3 py-2">
              <input v-model="row.name" type="text"
                class="w-full border-b border-neutral-200 bg-transparent py-1 text-xs text-neutral-900 outline-none focus:border-neutral-900"
                @change="saveRow(row)" />
            </td>

            <td class="px-3 py-2">
              <input v-model.number="row.price" type="number" min="0"
                class="w-full border-b border-neutral-200 bg-transparent py-1 text-xs text-neutral-900 outline-none focus:border-neutral-900"
                @change="saveRow(row)" />
            </td>

            <td class="px-3 py-2">
              <input v-model.number="row['order']" type="number" min="0"
                class="w-14 border-b border-neutral-200 bg-transparent py-1 text-xs text-neutral-900 outline-none focus:border-neutral-900"
                @change="saveRow(row)" />
            </td>

            <td class="px-3 py-2">
              <label class="flex cursor-pointer items-center gap-2">
                <input v-model="row.isActive" type="checkbox" class="h-4 w-4 accent-neutral-900"
                  @change="saveRow(row)" />
                <span class="text-[11px] text-neutral-500">
                  {{ row.isActive ? 'Так' : 'Ні' }}
                </span>
              </label>
            </td>

            <td class="px-3 py-2 text-right">
              <button :disabled="savingId === row.id"
                class="inline-flex h-7 w-7 items-center justify-center rounded hover:bg-red-50 disabled:opacity-40"
                :title="savingId === row.id ? 'Збереження...' : 'Видалити запис'" @click="deleteRow(row)">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-red-500" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M3 6h18" />
                  <path d="M8 6V4h8v2" />
                  <path d="M19 6l-1 14H6L5 6" />
                  <path d="M10 11v6" />
                  <path d="M14 11v6" />
                </svg>
              </button>
            </td>
          </tr>

          <tr v-if="!loading && !items.length">
            <td colspan="5" class="px-3 py-8 text-center text-sm italic text-neutral-400">
              Немає категорій
            </td>
          </tr>

          <tr v-if="loading">
            <td colspan="5" class="px-3 py-8 text-center text-sm italic text-neutral-400">
              Завантаження...
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>