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
    <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-7">
      <div>
        <div class="text-[11px] tracking-[0.14em] uppercase text-[var(--color-text-muted)] mb-2">
          Адмін-панель
        </div>
        <h1 class="font-serif text-[1.85rem] md:text-[2.05rem] font-semibold text-[var(--color-text)] leading-none">
          Квитки
        </h1>
      </div>

      <button @click="addRow" class="btn-primary self-start sm:self-auto">
        Додати категорію
      </button>
    </div>

    <div v-if="errorMsg" class="alert-error mb-6 max-w-2xl">
      {{ errorMsg }}
    </div>

    <div class="art-card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full min-w-[760px] text-sm table-fixed">
          <colgroup>
            <col />
            <col style="width: 140px" />
            <col style="width: 100px" />
            <col style="width: 90px" />
            <col style="width: 56px" />
          </colgroup>

          <thead class="bg-[var(--color-surface-soft)]">
            <tr class="border-b border-[var(--color-line)]">
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Назва
              </th>
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Ціна
              </th>
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Порядок
              </th>
              <th
                class="px-4 py-3 text-center text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Активна
              </th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>

          <tbody>
            <tr v-for="row in items" :key="row.id"
              class="border-b border-[color:rgba(49,91,125,0.14)] last:border-0 hover:bg-[var(--color-accent-faint)] transition-colors"
              :class="!row.isActive ? 'opacity-60' : ''">
              <td class="px-4 py-3 align-middle">
                <input v-model="row.name" type="text" class="field-input text-sm" @change="saveRow(row)" />
              </td>

              <td class="px-4 py-3 align-middle">
                <input v-model.number="row.price" type="number" min="0" class="field-input text-sm w-full"
                  @change="saveRow(row)" />
                <div class="text-[11px] text-[var(--color-text-muted)] mt-1 whitespace-nowrap">
                  {{ fmt(row.price) }}
                </div>
              </td>

              <td class="px-4 py-3 align-middle">
                <input v-model.number="row['order']" type="number" min="0" class="field-input text-sm w-full"
                  @change="saveRow(row)" />
              </td>

              <td class="px-4 py-3 align-middle text-center">
                <input v-model="row.isActive" type="checkbox" class="h-4 w-4 accent-[var(--color-accent)]"
                  @change="saveRow(row)" />
              </td>

              <td class="px-4 py-3 align-middle text-right">
                <button :disabled="savingId === row.id"
                  class="inline-flex h-8 w-8 items-center justify-center disabled:opacity-40 transition-colors hover:bg-[rgba(156,63,63,0.07)]"
                  :title="savingId === row.id ? 'Збереження...' : 'Видалити запис'" @click="deleteRow(row)">
                  <svg xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 text-[var(--color-danger)] opacity-75 hover:opacity-100" viewBox="0 0 24 24"
                    fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
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
              <td colspan="5" class="px-4 py-10 text-center text-sm italic text-[var(--color-text-muted)]">
                Немає категорій
              </td>
            </tr>

            <tr v-if="loading">
              <td colspan="5" class="px-4 py-10 text-center text-sm italic text-[var(--color-text-muted)]">
                Завантаження...
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>