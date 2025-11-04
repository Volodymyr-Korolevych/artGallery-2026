<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const loading = ref(true)
const errorMsg = ref<string|null>(null)
const items = ref<Record<string, any>[]>([])

const fetchAll = async () => {
  loading.value = true
  errorMsg.value = null
  const { data, error } = await supabase
    .from('contact_messages')
    .select('id,"name","email","message","createdAt"')
    .order('createdAt', { ascending: false })
  if (error) errorMsg.value = error.message
  items.value = data || []
  loading.value = false
}
onMounted(fetchAll)

const fmtDate = (v:any) => {
  if (!v) return '—'
  try { return new Date(v).toLocaleString('uk-UA') } catch { return String(v) }
}

const close = () => navigateTo('/admin')
</script>

<template>
  <div class="page">
    <div class="head">
      <h1 class="text-h5">Відгуки</h1>
      <div class="actions">
        <v-btn variant="text" @click="close">Закрити</v-btn>
      </div>
    </div>

    <v-alert v-if="errorMsg" type="error" density="compact" class="mb-3">{{ errorMsg }}</v-alert>

    <v-card>
      <v-table density="comfortable">
        <thead>
          <tr>
            <th style="width:70px">ID</th>
            <th style="width:200px">Ім’я</th>
            <th style="width:240px">Email</th>
            <th>Повідомлення</th>
            <th style="width:200px">Створено</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in items" :key="r.id">
            <td class="readonly">{{ r.id }}</td>
            <td>{{ r.name }}</td>
            <td>{{ r.email }}</td>
            <td style="max-width:520px; white-space:pre-wrap">{{ r.message }}</td>
            <td>{{ fmtDate(r.createdAt) }}</td>
          </tr>
          <tr v-if="!loading && items.length===0">
            <td colspan="5" class="muted">Поки немає відгуків</td>
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
.readonly { opacity: .75; }
.muted { color: rgba(0,0,0,.5); text-align:center; padding: 16px; }
</style>
