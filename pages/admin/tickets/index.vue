<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

type Row = Record<string, any>

const loading = ref(true)
const savingId = ref<number | null>(null)
const errorMsg = ref<string | null>(null)

const items = ref<Row[]>([])
const columns = ref<string[]>([])

// які поля не редагуємо / не показуємо
const hiddenCols = new Set(['created_at', 'updated_at'])
const readonlyCols = new Set(['id']) // id тільки для читання

const fetchTickets = async () => {
  loading.value = true
  errorMsg.value = null
  const { data, error } = await supabase
    .from('tickets')
    .select('*')
    .order('id', { ascending: true })
  if (error) { errorMsg.value = error.message; loading.value = false; return }
  items.value = data || []
  // сформуємо колонки динамічно за сукупністю ключів
  const keys = new Set<string>()
  for (const r of items.value) Object.keys(r).forEach(k => keys.add(k))
  columns.value = Array.from(keys).filter(k => !hiddenCols.has(k))
  loading.value = false
}

onMounted(fetchTickets)

const inputType = (val: any, key: string) => {
  if (typeof val === 'boolean' || key.toLowerCase().startsWith('is')) return 'boolean'
  if (typeof val === 'number') return 'number'
  // груба евристика для дат
  if (typeof val === 'string' && /\d{4}-\d{2}-\d{2}T/.test(val)) return 'datetime'
  return 'text'
}

const addRow = async () => {
  errorMsg.value = null
  try {
    // Мінімальна вставка — якщо в таблиці є NOT NULL-поля,
    // БД поверне помилку, яку покажемо користувачу.
    const payload: Row = { isActive: true }
    const { data, error } = await supabase
      .from('tickets')
      .insert(payload)
      .select('*')
      .single()
    if (error) throw error
    items.value.push(data)
    // оновимо список колонок, якщо з’явилися нові
    for (const k of Object.keys(data)) {
      if (!hiddenCols.has(k) && !columns.value.includes(k)) columns.value.push(k)
    }
  } catch (e: any) {
    errorMsg.value = e?.message || 'Помилка при створенні рядка. Перевірте обовʼязкові поля таблиці tickets.'
  }
}

const saveRow = async (row: Row) => {
  if (!row?.id) return
  errorMsg.value = null
  savingId.value = row.id
  try {
    const payload: Row = { ...row }
    // не апдейтимо службові/тільки-для-читання
    delete payload.id
    delete payload.created_at
    delete payload.updated_at

    const { error } = await supabase
      .from('tickets')
      .update(payload)
      .eq('id', row.id)
    if (error) throw error
  } catch (e: any) {
    errorMsg.value = e?.message || 'Помилка збереження'
  } finally {
    savingId.value = null
  }
}

const softDelete = async (row: Row) => {
  if (!row?.id) return
  errorMsg.value = null
  savingId.value = row.id
  try {
    const { error } = await supabase
      .from('tickets')
      .update({ isActive: false })
      .eq('id', row.id)
    if (error) throw error
    row.isActive = false
  } catch (e:any) {
    errorMsg.value = e?.message || 'Помилка деактивації'
  } finally {
    savingId.value = null
  }
}

const close = () => navigateTo('/admin')
</script>

<template>
  <div class="page">
    <div class="head">
      <h1 class="text-h5">Квитки</h1>
      <div class="actions">
        <v-btn variant="text" @click="close">Закрити</v-btn>
        <v-btn color="primary" @click="addRow">Додати</v-btn>
      </div>
    </div>

    <v-alert v-if="errorMsg" type="error" density="compact" class="mb-3">{{ errorMsg }}</v-alert>

    <v-card class="pa-2">
      <v-table density="comfortable">
        <thead>
          <tr>
            <th v-for="col in columns" :key="col">{{ col }}</th>
            <th style="width: 160px">Дії</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in items" :key="row.id">
            <td v-for="col in columns" :key="col">
              <template v-if="readonlyCols.has(col)">
                <span class="readonly">{{ row[col] }}</span>
              </template>
              <template v-else>
                <v-switch
                  v-if="inputType(row[col], col)==='boolean'"
                  v-model="row[col]"
                  color="primary"
                  inset
                  :false-value="false"
                  :true-value="true"
                  density="compact"
                />
                <v-text-field
                  v-else-if="inputType(row[col], col)==='number'"
                  v-model.number="row[col]"
                  type="number"
                  density="compact"
                  hide-details
                />
                <v-text-field
                  v-else-if="inputType(row[col], col)==='datetime'"
                  v-model="row[col]"
                  type="text"
                  density="compact"
                  hide-details
                  hint="ISO datetime"
                  persistent-hint
                />
                <v-text-field
                  v-else
                  v-model="row[col]"
                  type="text"
                  density="compact"
                  hide-details
                />
              </template>
            </td>
            <td class="row-actions">
              <v-btn
                size="small"
                color="primary"
                variant="tonal"
                :loading="savingId===row.id"
                @click="saveRow(row)"
              >
                Зберегти
              </v-btn>
              <v-btn
                size="small"
                color="error"
                variant="text"
                :loading="savingId===row.id"
                @click="softDelete(row)"
              >
                Деактивувати
              </v-btn>
            </td>
          </tr>
          <tr v-if="!loading && items.length===0">
            <td :colspan="columns.length + 1" class="muted">Поки немає рядків</td>
          </tr>
        </tbody>
      </v-table>
    </v-card>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 12px; }
.head { display:flex; align-items:center; justify-content:space-between; }
.actions { display:flex; gap:8px; }
.row-actions { white-space: nowrap; display:flex; gap:8px; }
.muted { color: rgba(0,0,0,.5); text-align:center; padding: 16px; }
.readonly { opacity: .75; }
</style>
