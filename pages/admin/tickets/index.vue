<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

type Row = {
  id: number
  name: string
  price: number
  isActive: boolean
  order?: number
  [k: string]: any
}

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
  const arr = items.value.map(r => (typeof r["order"] === 'number' ? r["order"] : 0))
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
  } catch (e:any) {
    errorMsg.value = e?.message || 'Помилка створення категорії'
  }
}

const saveRow = async (row: Row) => {
  if (!row?.id) return
  errorMsg.value = null
  savingId.value = row.id
  try {
    const payload:any = {
      name: row.name?.trim() ?? '',
      price: Number(row.price ?? 0),
      isActive: !!row.isActive,
      order: typeof row["order"] === 'number' ? row["order"] : null
    }
    if (!payload.name) { throw new Error('Назва не може бути порожньою') }
    if (payload.price < 0) { throw new Error('Ціна має бути >= 0') }

    const { error } = await supabase
      .from('ticket_categories')
      .update(payload)
      .eq('id', row.id)
    if (error) throw error
  } catch (e:any) {
    errorMsg.value = e?.message || 'Помилка збереження'
  } finally {
    savingId.value = null
  }
}

// М’яке "видалення": isActive = false
const softDelete = async (row: Row) => {
  if (!row?.id) return
  errorMsg.value = null
  savingId.value = row.id
  try {
    const { error } = await supabase
      .from('ticket_categories')
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
      <h1 class="text-h5">Квитки (категорії)</h1>
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
            <th style="width:240px">Назва</th>
            <th style="width:160px">Ціна</th>
            <th style="width:140px">Активний</th>
            <th style="width:140px">Порядок</th>
            <th style="width: 180px">Дії</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in items" :key="row.id">
            <td><v-text-field v-model="row.name" density="compact" hide-details /></td>
            <td><v-text-field v-model.number="row.price" type="number" min="0" step="0.01" density="compact" hide-details /></td>
            <td class="ta-center"><v-switch v-model="row.isActive" inset color="primary" density="compact" /></td>
            <td><v-text-field v-model.number="row['order']" type="number" min="0" step="1" density="compact" hide-details /></td>
            <td class="row-actions">
              <v-btn size="small" color="primary" variant="tonal" :loading="savingId===row.id" @click="saveRow(row)">Зберегти</v-btn>
            </td>
          </tr>
          <tr v-if="!loading && items.length===0">
            <td colspan="6" class="muted">Поки немає категорій</td>
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
.readonly { opacity: .75; }
.muted { color: rgba(0,0,0,.5); text-align:center; padding: 16px; }
.ta-center { text-align:center; }
</style>
