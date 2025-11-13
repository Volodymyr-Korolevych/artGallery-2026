<script setup lang="ts">
definePageMeta({ layout: 'default' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const loading = ref(true)

type Exhibition = {
  id: number
  title: string
  status: 'past'|'current'|'upcoming'|null
}
type Category = {
  id: number
  name: string
  price: number
  isActive: boolean
  order: number | null
}
type OrderRow = {
  id: number
  createdAt: string
  exhibitionId: number | null
  categoryId: number
  quantity: number
  amount: number
  category?: { name: string } | null
  exhibition?: { title: string } | null
}

const currentEx = ref<Exhibition|null>(null)
const cats = ref<Category[]>([])
const qty = reactive<Record<number, number>>({}) // categoryId -> quantity
const placing = ref(false)
const showHistory = ref(false)
const history = ref<OrderRow[]>([])

const fetchData = async () => {
  loading.value = true

  // 1) Поточна виставка (назва на всю ширину)
  const { data: e } = await supabase
    .from('exhibitions')
    .select('id,title,status')
    .eq('status', 'current')
    .eq('isPublished', true)
    .order('startDate', { ascending: false })
    .limit(1)
    .maybeSingle()
  currentEx.value = (e as Exhibition) || null

  // 2) Категорії квитків (активні, у потрібному порядку)
  const { data: c } = await supabase
    .from('ticket_categories')
    .select('id,name,price,"isActive","order"')
    .eq('isActive', true)
    .order('order', { ascending: true })
    .order('id', { ascending: true })

  cats.value = (c || []) as Category[]
  cats.value.forEach(cat => { if (!(cat.id in qty)) qty[cat.id] = 0 })

  loading.value = false
}

onMounted(fetchData)

// Підсумок по вибору (тільки ненульові рядки)
const chosen = computed(() =>
  cats.value
    .map(c => ({ ...c, quantity: Number(qty[c.id] || 0), sum: Number(qty[c.id] || 0) * Number(c.price) }))
    .filter(r => r.quantity > 0)
)
const total = computed(() => chosen.value.reduce((s, r) => s + r.sum, 0))

const inc = (id: number) => { qty[id] = Math.min(99, Number(qty[id] || 0) + 1) }
const dec = (id: number) => { qty[id] = Math.max(0, Number(qty[id] || 0) - 1) }
const setQty = (id: number, val: number) => { qty[id] = Math.max(0, Math.min(99, Math.floor(val || 0))) }

const placeOrder = async () => {
  if (!user.value) { return navigateTo('/login') }
  if (!currentEx.value) {
    return alert('Немає поточної виставки для оформлення замовлення.')
  }
  if (!chosen.value.length) return

  placing.value = true
  try {
    const rows = chosen.value.map(r => ({
      userId: user.value!.id,
      exhibitionId: currentEx.value!.id,
      categoryId: r.id,
      quantity: r.quantity,
      amount: r.sum
    }))
    const { error } = await supabase.from('ticket_orders').insert(rows)
    if (error) throw error

    // Обнулити вибір
    cats.value.forEach(c => qty[c.id] = 0)
    await loadHistory()
    showHistory.value = true
  } catch (e:any) {
    console.error(e)
    alert('Помилка під час оформлення замовлення.')
  } finally {
    placing.value = false
  }
}

const loadHistory = async () => {
  if (!user.value) { history.value = []; return }
  const { data } = await supabase
    .from('ticket_orders')
    .select('id,"createdAt","exhibitionId","categoryId",quantity,amount, category:ticket_categories(name), exhibition:exhibitions(title)')
    .eq('userId', user.value.id)
    .order('createdAt', { ascending: false })
    .limit(200)
  history.value = (data || []) as unknown as OrderRow[]
}

const toggleHistory = async () => {
  if (!showHistory.value) {
    await loadHistory()
  }
  showHistory.value = !showHistory.value
}

const fmt = (v:number) => new Intl.NumberFormat('uk-UA', { style: 'currency', currency: 'UAH' }).format(v || 0)
const fmtDate = (s:string) => new Date(s).toLocaleString('uk-UA', { year:'numeric', month:'2-digit', day:'2-digit', hour:'2-digit', minute:'2-digit' })
</script>

<template>
  <div class="container page serif">
    <v-skeleton-loader v-if="loading" type="article"></v-skeleton-loader>

    <template v-else>
      <!-- Назва поточної виставки на всю ширину -->
      <h1 class="title">{{ currentEx?.title || 'Немає поточної виставки' }}</h1>

      <div class="layout">
        <!-- ЛІВОРУЧ: вибір квитків -->
        <div class="left">
          <div class="lead">Замовте квитки згідно діючих категорій відвідувачів</div>

          <v-table density="comfortable" class="tbl">
            <thead>
              <tr>
                <th style="width:45%">Категорія</th>
                <th style="width:20%">Ціна</th>
                <th style="width:35%">Кількість</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="c in cats" :key="c.id">
                <td>{{ c.name }}</td>
                <td>{{ fmt(Number(c.price)) }}</td>
                <td class="qty">
                  <v-btn size="small" variant="tonal" @click="dec(c.id)">−</v-btn>
                  <v-text-field
                    type="number"
                    variant="outlined"
                    density="compact"
                    hide-details
                    class="qty-inp"
                    :model-value="qty[c.id]"
                    @update:model-value="val => setQty(c.id, Number(val))"
                    min="0" max="99"
                  />
                  <v-btn size="small" variant="tonal" @click="inc(c.id)">+</v-btn>
                </td>
              </tr>
            </tbody>
          </v-table>

          <div class="mt">
            <v-btn color="primary" :disabled="!chosen.length || !currentEx" :loading="placing" @click="placeOrder">
              Оформити замовлення
            </v-btn>
          </div>
        </div>

        <!-- ПРАВОРУЧ: Підсумок (лише ненульові рядки) -->
        <div class="right">
          <h2 class="h">Підсумок</h2>
          <v-table density="comfortable" class="tbl">
            <thead>
              <tr><th>Категорія</th><th>Кількість</th><th>Сума</th></tr>
            </thead>
            <tbody>
              <tr v-for="r in chosen" :key="r.id">
                <td>{{ r.name }}</td>
                <td>{{ r.quantity }}</td>
                <td>{{ fmt(r.sum) }}</td>
              </tr>
              <tr v-if="!chosen.length">
                <td colspan="3" class="muted">Немає вибраних квитків</td>
              </tr>
            </tbody>
          </v-table>

          <div class="total">
            <div>Сума:</div>
            <div class="sum">{{ fmt(total) }}</div>
          </div>

          <v-btn variant="tonal" class="mt" @click="toggleHistory">
            {{ showHistory ? 'Сховати історію ваших замовлень' : 'Показати історію ваших замовлень' }}
          </v-btn>
        </div>
      </div>

      <!-- НИЖЧЕ: ІСТОРІЯ ЗАМОВЛЕНЬ (на всю ширину) -->
      <div v-if="showHistory" class="history">
        <h2 class="h">Історія ваших замовлень</h2>
        <v-table density="comfortable" class="tbl">
          <thead>
            <tr>
              <th>Дата замовлення</th>
              <th>Назва виставки</th>
              <th>Категорія квитків</th>
              <th>Кількість</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in history" :key="row.id">
              <td>{{ fmtDate(row.createdAt) }}</td>
              <td>{{ row.exhibition?.title || '—' }}</td>
              <td>{{ row.category?.name || '—' }}</td>
              <td>{{ row.quantity }}</td>
            </tr>
            <tr v-if="!history.length">
              <td colspan="4" class="muted">Історія порожня.</td>
            </tr>
          </tbody>
        </v-table>
      </div>

      <!-- Якщо користувач не залогінений -->
      <v-alert type="info" variant="tonal" class="mt" v-if="!user">
        Щоби оформити замовлення та переглядати історію, <NuxtLink to="/login">увійдіть</NuxtLink>.
      </v-alert>
    </template>
  </div>
</template>

<style scoped>
.serif{ font-family: "Cormorant Garamond", serif; }
.page{ padding-top:18px; padding-bottom:28px; }
.title{ font-size: clamp(28px, 3.4vw, 44px); margin-bottom: 14px; }

.layout{
  display: grid;
  grid-template-columns: 1.1fr .9fr;
  gap: 20px;
  align-items: start;
}

.lead{ font-size: 18px; margin-bottom: 8px; }
.tbl :deep(th){ font-weight:600; }
.qty{ display:flex; align-items:center; gap:8px; }
.qty-inp{ width: 80px; }

.h{ font-size: 22px; margin-bottom: 8px; }
.total{
  display:flex; align-items:center; justify-content:space-between;
  font-size: 18px; margin-top: 8px;
}
.sum{ font-weight: 700; }

.mt{ margin-top: 10px; }

.history{ margin-top: 20px; }

@media (max-width: 1000px){
  .layout{ grid-template-columns: 1fr; }
}
</style>
