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
    <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-8">
      <div>
        <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-2">
          Адмін-панель
        </div>
        <h1 class="font-serif text-[2rem] md:text-[2.25rem] font-semibold text-[var(--color-text)] leading-none">
          Квитки
        </h1>
      </div>

      <button @click="addRow" class="btn-primary text-xs self-start sm:self-auto">
        Додати категорію
      </button>
    </div>

    <div v-if="errorMsg" class="alert-error mb-6 max-w-2xl">
      {{ errorMsg }}
    </div>

    <div class="art-card overflow-hidden">
      <div class="px-5 md:px-6 py-4 border-b border-[var(--color-line)] bg-[var(--color-surface-soft)]">
        <div
          class="grid grid-cols-[minmax(0,1fr)_120px_90px_110px_40px] gap-4 items-center text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)]">
          <div>Назва</div>
          <div>Ціна</div>
          <div>Порядок</div>
          <div>Активна</div>
          <div></div>
        </div>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full min-w-[760px] text-sm">
          <tbody>
            <tr v-for="row in items" :key="row.id"
              class="border-b border-[color:rgba(188,197,203,0.25)] last:border-0 hover:bg-[var(--color-accent-soft)]/40 transition-colors"
              :class="!row.isActive ? 'opacity-60' : ''">
              <td class="px-5 py-4 align-middle">
                <div class="max-w-md">
                  <input v-model="row.name" type="text" class="field-input text-sm" @change="saveRow(row)" />
                </div>
              </td>

              <td class="px-5 py-4 align-middle">
                <div class="w-24">
                  <input v-model.number="row.price" type="number" min="0" class="field-input text-sm"
                    @change="saveRow(row)" />
                </div>
                <div class="text-xs text-[var(--color-text-muted)] mt-1">
                  {{ fmt(row.price) }}
                </div>
              </td>

              <td class="px-5 py-4 align-middle">
                <input v-model.number="row['order']" type="number" min="0" class="field-input text-sm w-16"
                  @change="saveRow(row)" />
              </td>

              <td class="px-5 py-4 align-middle">
                <label class="inline-flex items-center gap-2 cursor-pointer">
                  <input v-model="row.isActive" type="checkbox" class="h-4 w-4 accent-[var(--color-accent)]"
                    @change="saveRow(row)" />
                  <span class="text-sm text-[var(--color-text-soft)]">
                    {{ row.isActive ? 'Так' : 'Ні' }}
                  </span>
                </label>
              </td>

              <td class="px-5 py-4 align-middle text-right">
                <button :disabled="savingId === row.id"
                  class="inline-flex h-9 w-9 items-center justify-center hover:bg-red-50 disabled:opacity-40 transition-colors"
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
              <td colspan="5" class="px-5 py-12 text-center text-sm italic text-[var(--color-text-muted)]">
                Немає категорій
              </td>
            </tr>

            <tr v-if="loading">
              <td colspan="5" class="px-5 py-12 text-center text-sm italic text-[var(--color-text-muted)]">
                Завантаження...
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>