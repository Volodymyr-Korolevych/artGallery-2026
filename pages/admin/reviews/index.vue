<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const loading = ref(true)
const errorMsg = ref<string|null>(null)
const items = ref<Record<string, any>[]>([])

// Сортуємо за датою створення "нові зверху".
// Поле може називатись created_at або createdAt — спробуємо обидва:
const fetchReviews = async () => {
  loading.value = true
  errorMsg.value = null

  // Перший варіант: created_at
  let q = supabase.from('reviews').select('*').order('created_at', { ascending: false })
  let { data, error } = await q
  // Якщо помилка сортування (немає такого поля) — пробуємо createdAt
  if (error) {
    const q2 = supabase.from('reviews').select('*').order('createdAt', { ascending: false })
    const res2 = await q2
    data = res2.data
    error = res2.error
  }
  if (error) {
    errorMsg.value = error.message
  } else {
    items.value = data || []
  }
  loading.value = false
}

onMounted(fetchReviews)

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
            <th>ID</th>
            <th>Автор</th>
            <th>Рейтинг</th>
            <th>Текст</th>
            <th>Створено</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in items" :key="r.id">
            <td>{{ r.id ?? '—' }}</td>
            <td>{{ r.author ?? r.userName ?? r.email ?? '—' }}</td>
            <td>{{ r.rating ?? '—' }}</td>
            <td style="max-width:520px">{{ r.text ?? r.content ?? '—' }}</td>
            <td>{{ fmtDate(r.created_at ?? r.createdAt) }}</td>
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
.muted { color: rgba(0,0,0,.5); text-align:center; padding: 16px; }
</style>
