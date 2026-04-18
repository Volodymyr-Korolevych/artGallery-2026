<script setup lang="ts">
definePageMeta({ layout: 'default' })
import QRCode from 'qrcode'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const loading = ref(true)

type Exhibition = { id: number; title: string; status: 'past'|'current'|'upcoming'|null }
type Category   = { id: number; name: string; price: number; isActive: boolean; order: number|null }
type OrderRow   = { id: number; createdAt: string; exhibitionId: number|null; categoryId: number; quantity: number; amount: number; category?: {name:string}|null; exhibition?: {title:string}|null }

const currentEx = ref<Exhibition|null>(null)
const cats = ref<Category[]>([])
const qty = reactive<Record<number, number>>({})
const placing = ref(false); const showHistory = ref(false)
const history = ref<OrderRow[]>([]); const message = ref(''); const qr = ref('')
const DRAFT_KEY = 'ticketsDraft_v1'

const fetchData = async () => {
  loading.value = true
  const { data: e } = await supabase.from('exhibitions').select('id,title,status').eq('status','current').eq('isPublished',true).order('startDate',{ascending:false}).limit(1).maybeSingle()
  currentEx.value = (e as Exhibition) || null
  const { data: c } = await supabase.from('ticket_categories').select('id,name,price,"isActive","order"').eq('isActive',true).order('order',{ascending:true}).order('id',{ascending:true})
  cats.value = (c || []) as Category[]
  cats.value.forEach(cat => { if (!(cat.id in qty)) qty[cat.id] = 0 })
  loading.value = false
  restoreDraft()
}

const saveDraft = () => {
  if (typeof window === 'undefined') return
  const payload = { exhibitionId: currentEx.value?.id ?? null, qty: Object.fromEntries(Object.entries(qty).filter(([_, v]) => Number(v) > 0).map(([k,v]) => [k, Number(v)])) }
  if (!payload.exhibitionId && Object.keys(payload.qty).length === 0) { localStorage.removeItem(DRAFT_KEY); return }
  localStorage.setItem(DRAFT_KEY, JSON.stringify(payload))
}

const restoreDraft = () => {
  if (typeof window === 'undefined') return
  const raw = localStorage.getItem(DRAFT_KEY)
  if (!raw) return
  try {
    const parsed = JSON.parse(raw) as { exhibitionId: number|null; qty: Record<string, number> }
    if (parsed.exhibitionId && currentEx.value && parsed.exhibitionId !== currentEx.value.id) return
    Object.entries(parsed.qty).forEach(([key, val]) => {
      const id = Number(key)
      if (cats.value.some(c => c.id === id)) qty[id] = Number(val) || 0
    })
  } catch(e) { console.error('Failed to restore draft', e) }
}

onMounted(fetchData)

const chosen = computed(() => cats.value.map(c => ({...c, quantity: Number(qty[c.id]||0), sum: Number(qty[c.id]||0)*Number(c.price)})).filter(r => r.quantity > 0))
const total  = computed(() => chosen.value.reduce((s,r) => s+r.sum, 0))
const inc = (id:number) => { qty[id] = Math.min(99, Number(qty[id]||0)+1) }
const dec = (id:number) => { qty[id] = Math.max(0,  Number(qty[id]||0)-1) }
const setQty = (id:number, val:number) => { qty[id] = Math.max(0, Math.min(99, Math.floor(val||0))) }

const placeOrder = async () => {
  if (!currentEx.value) { alert('Немає поточної виставки для оформлення замовлення.'); return }
  if (!chosen.value.length) return
  if (!user.value) { saveDraft(); return navigateTo('/login?next='+encodeURIComponent('/tickets')) }
  placing.value = true
  try {
    const rows = chosen.value.map(r => ({ userId: user.value!.id, exhibitionId: currentEx.value!.id, categoryId: r.id, quantity: r.quantity, amount: r.sum }))
    const { data, error } = await supabase.from('ticket_orders').insert(rows)
    if (error) throw error
    const url = await QRCode.toDataURL(`order:${user.value!.id}`)
    qr.value = url; message.value = 'Замовлення успішно створено.'
    cats.value.forEach(c => qty[c.id] = 0)
    if (typeof window !== 'undefined') localStorage.removeItem(DRAFT_KEY)
    await loadHistory(); showHistory.value = true
  } catch(e: any) { console.error(e); alert('Помилка під час оформлення.') }
  finally { placing.value = false }
}

const loadHistory = async () => {
  if (!user.value) { history.value = []; return }
  const { data } = await supabase.from('ticket_orders')
    .select('id,"createdAt","exhibitionId","categoryId",quantity,amount, category:ticket_categories(name), exhibition:exhibitions(title)')
    .eq('userId', user.value.id).order('createdAt',{ascending:false}).limit(200)
  history.value = (data||[]) as unknown as OrderRow[]
}

const toggleHistory = async () => {
  if (!showHistory.value) await loadHistory()
  showHistory.value = !showHistory.value
}

const fmt = (v:number) => new Intl.NumberFormat('uk-UA', { style:'currency', currency:'UAH' }).format(v||0)
const fmtDate = (s:string) => new Date(s).toLocaleString('uk-UA', { year:'numeric', month:'2-digit', day:'2-digit', hour:'2-digit', minute:'2-digit' })
</script>

<template>
  <div>
    <!-- Loading -->
    <div v-if="loading" class="space-y-4 animate-pulse">
      <div class="h-10 bg-neutral-200 rounded w-2/3"></div>
      <div class="h-4 bg-neutral-100 rounded w-full"></div>
      <div class="h-4 bg-neutral-100 rounded w-4/5"></div>
    </div>

    <template v-else>
      <div class="divider"></div>
      <h1 class="font-serif text-4xl lg:text-5xl font-semibold text-neutral-900 mb-2 leading-tight">
        {{ currentEx?.title || 'Немає поточної виставки' }}
      </h1>
      <p class="text-sm text-neutral-500 mb-10">Замовте квитки згідно діючих категорій відвідувачів</p>

      <div class="grid grid-cols-1 lg:grid-cols-5 gap-10 items-start">

        <!-- Left: ticket selection -->
        <div class="lg:col-span-3">
          <div class="bg-white border border-neutral-100 overflow-hidden">
            <table class="w-full text-sm">
              <thead>
                <tr class="border-b border-neutral-100">
                  <th class="text-left px-5 py-3.5 text-xs tracking-widest uppercase text-neutral-400 font-medium w-[45%]">Категорія</th>
                  <th class="text-left px-5 py-3.5 text-xs tracking-widest uppercase text-neutral-400 font-medium w-[25%]">Ціна</th>
                  <th class="text-left px-5 py-3.5 text-xs tracking-widest uppercase text-neutral-400 font-medium">Кількість</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="c in cats" :key="c.id" class="border-b border-neutral-50 last:border-0 hover:bg-neutral-50 transition-colors">
                  <td class="px-5 py-4 font-serif text-base text-neutral-900">{{ c.name }}</td>
                  <td class="px-5 py-4 text-sm text-neutral-600">{{ fmt(Number(c.price)) }}</td>
                  <td class="px-5 py-4">
                    <div class="flex items-center gap-2">
                      <button @click="dec(c.id)" class="w-7 h-7 border border-neutral-200 text-neutral-600 hover:border-neutral-900 hover:text-neutral-900 transition-colors text-sm flex items-center justify-center">−</button>
                      <input
                        type="number"
                        class="w-14 h-7 border-b border-neutral-300 text-center text-sm focus:outline-none focus:border-neutral-900 bg-transparent"
                        :value="qty[c.id]"
                        @input="e => setQty(c.id, Number((e.target as HTMLInputElement).value))"
                        min="0" max="99"
                      />
                      <button @click="inc(c.id)" class="w-7 h-7 border border-neutral-200 text-neutral-600 hover:border-neutral-900 hover:text-neutral-900 transition-colors text-sm flex items-center justify-center">+</button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="mt-5">
            <button
              class="btn-primary text-xs"
              :disabled="!chosen.length || !currentEx || placing"
              @click="placeOrder"
            >
              <span v-if="placing">Оформлення...</span>
              <span v-else>Оформити замовлення</span>
            </button>
          </div>
        </div>

        <!-- Right: summary -->
        <div class="lg:col-span-2">
          <div class="bg-white border border-neutral-100 p-6">
            <div class="text-xs tracking-widest uppercase text-neutral-400 mb-4">Підсумок</div>
            <div class="space-y-3 min-h-[80px]">
              <div v-if="!chosen.length" class="text-sm text-neutral-400 italic">Немає вибраних квитків</div>
              <div v-for="r in chosen" :key="r.id" class="flex justify-between items-center text-sm">
                <span class="text-neutral-700">{{ r.name }} × {{ r.quantity }}</span>
                <span class="font-medium text-neutral-900">{{ fmt(r.sum) }}</span>
              </div>
            </div>
            <div class="border-t border-neutral-100 mt-4 pt-4 flex justify-between items-center">
              <span class="text-xs tracking-widest uppercase text-neutral-500">Разом</span>
              <span class="font-serif text-xl font-semibold text-neutral-900">{{ fmt(total) }}</span>
            </div>
          </div>

          <button v-if="user" @click="toggleHistory" class="btn-ghost text-xs mt-4 px-0 underline underline-offset-2">
            {{ showHistory ? 'Сховати історію замовлень' : 'Показати історію замовлень' }}
          </button>
        </div>
      </div>

      <!-- Alerts & QR -->
      <div v-if="message" class="alert-success mt-6">{{ message }}</div>
      <img v-if="qr" :src="qr" alt="QR код замовлення" class="mt-4 w-36 h-36" />

      <!-- History -->
      <div v-if="showHistory" class="mt-10">
        <h2 class="font-serif text-2xl font-semibold text-neutral-900 mb-5">Історія ваших замовлень</h2>
        <div class="bg-white border border-neutral-100 overflow-hidden">
          <table class="w-full text-sm">
            <thead>
              <tr class="border-b border-neutral-100">
                <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium">Дата</th>
                <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium">Виставка</th>
                <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium">Категорія</th>
                <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium">К-сть</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in history" :key="row.id" class="border-b border-neutral-50 last:border-0 hover:bg-neutral-50">
                <td class="px-5 py-3.5 text-neutral-600">{{ fmtDate(row.createdAt) }}</td>
                <td class="px-5 py-3.5 text-neutral-800 font-serif">{{ row.exhibition?.title || '—' }}</td>
                <td class="px-5 py-3.5 text-neutral-600">{{ row.category?.name || '—' }}</td>
                <td class="px-5 py-3.5 text-neutral-800 font-medium">{{ row.quantity }}</td>
              </tr>
              <tr v-if="!history.length">
                <td colspan="4" class="px-5 py-6 text-sm text-neutral-400 text-center italic">Історія порожня.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Not logged in -->
      <div v-if="!user" class="alert-info mt-8">
        Щоби оформити замовлення та переглядати історію,
        <NuxtLink to="/login" class="underline underline-offset-2 font-medium ml-1">увійдіть</NuxtLink>.
      </div>
    </template>
  </div>
</template>
