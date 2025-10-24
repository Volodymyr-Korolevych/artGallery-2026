<script setup lang="ts">
import QRCode from 'qrcode'
const user = useSupabaseUser()
const client = useSupabaseClient()

const { data: categories } = await useAsyncData('ticketCats', async () => {
  const { data } = await client.from('ticket_categories').select('*').eq('isActive', true).order('order')
  return data || []
})

const selected = ref<{ id: number, qty: number }[]>([])
const total = computed(() => {
  return selected.value.reduce((s, it) => {
    const cat = categories.value.find(c => c.id === it.id)
    return s + (cat ? (cat.price * it.qty) : 0)
  }, 0)
})

function setQty(id: number, qty: number) {
  const item = selected.value.find(x => x.id === id)
  if (!item && qty > 0) selected.value.push({ id, qty })
  if (item) item.qty = Math.max(0, qty)
  selected.value = selected.value.filter(x => x.qty > 0)
}

const message = ref('')
const qr = ref('')
const placing = ref(false)

async function placeOrder() {
  if (!user.value) {
    return navigateTo('/login?next=/tickets')
  }
  placing.value = true
  message.value = ''
  const now = new Date().toISOString()
  // create orders per category
  for (const it of selected.value) {
    const { data, error } = await client
      .from('ticket_orders')
      .insert({ userId: user.value.id, categoryId: it.id, amount: it.qty, createdAt: now })
      .select('id')
      .single()
    if (error) { placing.value = false; message.value = error.message; return }
    const url = await QRCode.toDataURL(`order:${data.id}`)
    await client.from('ticket_orders').update({ qrCode: url }).eq('id', data.id)
    qr.value = url
  }
  placing.value = false
  message.value = 'Замовлення успішно створено.'
}

const { data: myOrders, refresh } = await useAsyncData('myOrders', async () => {
  if (!user.value) return []
  const { data } = await client.from('ticket_orders').select('id, createdAt, amount, categoryId')
    .eq('userId', user.value.id).order('createdAt', { ascending: false })
  return data || []
})
watch(user, () => refresh())
</script>

<template>
  <div>
    <h1 class="text-h4 mb-4">Квитки</h1>
    <v-row>
      <v-col cols="12" md="8">
        <v-table>
          <thead>
            <tr><th>Категорія</th><th>Ціна</th><th>Кількість</th></tr>
          </thead>
          <tbody>
            <tr v-for="c in categories" :key="c.id">
              <td>{{ c.name }}</td>
              <td>{{ c.price }}</td>
              <td>
                <v-btn size="small" @click="setQty(c.id, (selected.find(s=>s.id===c.id)?.qty||0)-1)">-</v-btn>
                <span class="mx-2">{{ selected.find(s=>s.id===c.id)?.qty || 0 }}</span>
                <v-btn size="small" @click="setQty(c.id, (selected.find(s=>s.id===c.id)?.qty||0)+1)">+</v-btn>
              </td>
            </tr>
          </tbody>
        </v-table>
      </v-col>
      <v-col cols="12" md="4">
        <v-card class="pa-4">
          <div class="text-h6">Підсумок</div>
          <div class="my-2">Сума: {{ total }}</div>
          <v-btn :loading="placing" color="primary" @click="placeOrder">Замовити</v-btn>
          <v-alert v-if="message" type="success" :text="message" class="mt-3" />
          <img v-if="qr" :src="qr" alt="QR" class="mt-3" />
        </v-card>
        <div v-if="user" class="mt-6">
          <v-btn @click="refresh">Показати історію Ваших замовлень</v-btn>
          <v-table v-if="myOrders?.length" class="mt-3">
            <thead><tr><th>Дата</th><th>Категорія</th><th>Кількість</th></tr></thead>
            <tbody>
              <tr v-for="o in myOrders" :key="o.id">
                <td>{{ o.createdAt }}</td>
                <td>{{ o.categoryId }}</td>
                <td>{{ o.amount }}</td>
              </tr>
            </tbody>
          </v-table>
        </div>
      </v-col>
    </v-row>
  </div>
</template>
