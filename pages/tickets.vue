<script setup lang="ts">
definePageMeta({ layout: 'default' })
import QRCode from 'qrcode'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const route = useRoute()
const loading = ref(true)

type Exhibition = { id: number; title: string; status: 'past' | 'current' | 'upcoming' | null }
type Category = { id: number; name: string; price: number; isActive: boolean; order: number | null }
type OrderRow = { id: number; createdAt: string; exhibitionId: number | null; categoryId: number; quantity: number; amount: number; category?: { name: string } | null; exhibition?: { title: string } | null }

const currentEx = ref<Exhibition | null>(null)
const cats = ref<Category[]>([])
const qty = reactive<Record<number, number>>({})
const placing = ref(false); const showHistory = ref(false)
const history = ref<OrderRow[]>([]); const message = ref(''); const qr = ref('')
const DRAFT_KEY = 'ticketsDraft_v1'

const fetchData = async () => {
  loading.value = true
  const { data: e } = await supabase.from('exhibitions').select('id,title,status').eq('status', 'current').eq('isPublished', true).order('startDate', { ascending: false }).limit(1).maybeSingle()
  currentEx.value = (e as Exhibition) || null
  const { data: c } = await supabase.from('ticket_categories').select('id,name,price,"isActive","order"').eq('isActive', true).order('order', { ascending: true }).order('id', { ascending: true })
  cats.value = (c || []) as Category[]
  cats.value.forEach(cat => { if (!(cat.id in qty)) qty[cat.id] = 0 })
  loading.value = false
  if (route.query.restoreDraft === '1') {
    restoreDraft()
  }
}

const saveDraft = () => {
  if (typeof window === 'undefined') return
  const payload = { exhibitionId: currentEx.value?.id ?? null, qty: Object.fromEntries(Object.entries(qty).filter(([_, v]) => Number(v) > 0).map(([k, v]) => [k, Number(v)])) }
  if (!payload.exhibitionId && Object.keys(payload.qty).length === 0) { localStorage.removeItem(DRAFT_KEY); return }
  localStorage.setItem(DRAFT_KEY, JSON.stringify(payload))
}

const restoreDraft = () => {
  if (typeof window === 'undefined') return
  const raw = localStorage.getItem(DRAFT_KEY)
  if (!raw) return
  try {
    const parsed = JSON.parse(raw) as { exhibitionId: number | null; qty: Record<string, number> }
    if (parsed.exhibitionId && currentEx.value && parsed.exhibitionId !== currentEx.value.id) return

    Object.entries(parsed.qty).forEach(([key, val]) => {
      const id = Number(key)
      if (cats.value.some(c => c.id === id)) qty[id] = Number(val) || 0
    })

    navigateTo('/tickets', { replace: true })
  } catch (e) {
    console.error('Failed to restore draft', e)
  }
}

onMounted(fetchData)

const chosen = computed(() => cats.value.map(c => ({ ...c, quantity: Number(qty[c.id] || 0), sum: Number(qty[c.id] || 0) * Number(c.price) })).filter(r => r.quantity > 0))
const total = computed(() => chosen.value.reduce((s, r) => s + r.sum, 0))
const inc = (id: number) => { qty[id] = Math.min(99, Number(qty[id] || 0) + 1) }
const dec = (id: number) => { qty[id] = Math.max(0, Number(qty[id] || 0) - 1) }
const setQty = (id: number, val: number) => { qty[id] = Math.max(0, Math.min(99, Math.floor(val || 0))) }

const placeOrder = async () => {
  if (!currentEx.value) { alert('Немає поточної виставки для оформлення замовлення.'); return }
  if (!chosen.value.length) return
  if (!user.value) {
    saveDraft()
    return navigateTo('/login?next=' + encodeURIComponent('/tickets?restoreDraft=1'))
  }
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
  } catch (e: any) { console.error(e); alert('Помилка під час оформлення.') }
  finally { placing.value = false }
}

const loadHistory = async () => {
  if (!user.value) { history.value = []; return }
  const { data } = await supabase.from('ticket_orders')
    .select('id,"createdAt","exhibitionId","categoryId",quantity,amount, category:ticket_categories(name), exhibition:exhibitions(title)')
    .eq('userId', user.value.id).order('createdAt', { ascending: false }).limit(200)
  history.value = (data || []) as unknown as OrderRow[]
}

const toggleHistory = async () => {
  if (!showHistory.value) await loadHistory()
  showHistory.value = !showHistory.value
}

const fmt = (v: number) => new Intl.NumberFormat('uk-UA', { style: 'currency', currency: 'UAH' }).format(v || 0)
const fmtDate = (s: string) => new Date(s).toLocaleString('uk-UA', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
</script>

<template>
  <div class="container py-9 md:py-10 lg:py-12">
    <div v-if="loading" class="space-y-5 animate-pulse">
      <div class="divider"></div>
      <div class="h-10 skeleton w-2/3"></div>
      <div class="h-4 skeleton w-full"></div>
      <div class="h-4 skeleton w-4/5"></div>
      <div class="grid grid-cols-1 lg:grid-cols-5 gap-8 pt-4">
        <div class="lg:col-span-3 skeleton h-[300px]"></div>
        <div class="lg:col-span-2 skeleton h-[230px]"></div>
      </div>
    </div>

    <template v-else>
      <div class="max-w-3xl mb-7 md:mb-8">
        <div class="divider"></div>
        <h1 class="mb-2">
          {{ currentEx?.title || 'Немає поточної виставки' }}
        </h1>
        <p class="text-sm md:text-base text-[var(--color-text-muted)]">
          Замовте квитки згідно діючих категорій відвідувачів
        </p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-[minmax(0,0.95fr)_minmax(300px,0.75fr)] gap-6 lg:gap-7 items-start">
        <!-- Left: ticket selection -->
        <div class="max-w-[680px]">
          <div class="art-card">
            <div class="px-4 md:px-5 py-3 border-b border-[var(--color-line)] bg-[var(--color-surface-soft)]">
              <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)]">
                Категорії квитків
              </div>
            </div>

            <div class="divide-y divide-[color:rgba(49,91,125,0.18)]">
              <div v-for="c in cats" :key="c.id"
                class="px-4 md:px-5 py-3 md:py-3.5 flex items-center justify-between gap-4">
                <div class="min-w-0 pr-3">
                  <div class="font-serif text-[1rem] md:text-[1.08rem] text-[var(--color-text)] leading-tight">
                    {{ c.name }}
                  </div>
                  <div class="text-[13px] text-[var(--color-text-soft)] mt-0.5">
                    {{ fmt(Number(c.price)) }}
                  </div>
                </div>

                <div
                  class="shrink-0 flex items-center rounded-full border border-[var(--color-line-strong)] bg-[var(--color-surface)] overflow-hidden">
                  <button @click="dec(c.id)"
                    class="w-9 h-9 flex items-center justify-center text-[17px] text-[var(--color-accent)] hover:bg-[var(--color-accent-soft)] hover:text-[var(--color-accent-hover)] transition-colors"
                    type="button" aria-label="Зменшити кількість">
                    −
                  </button>

                  <span
                    class="w-10 h-9 flex items-center justify-center text-sm font-medium text-[var(--color-text)] border-x border-[var(--color-line)]">
                    {{ qty[c.id] }}
                  </span>

                  <button @click="inc(c.id)"
                    class="w-9 h-9 flex items-center justify-center text-[17px] text-[var(--color-accent)] hover:bg-[var(--color-accent-soft)] hover:text-[var(--color-accent-hover)] transition-colors"
                    type="button" aria-label="Збільшити кількість">
                    +
                  </button>
                </div>
              </div>

              <div v-if="!cats.length" class="px-4 md:px-5 py-7 text-sm text-[var(--color-text-muted)] italic">
                Активні категорії квитків відсутні.
              </div>
            </div>
          </div>

          <div class="mt-4 flex flex-wrap items-center gap-3">
            <button class="btn-primary text-xs" :disabled="!chosen.length || !currentEx || placing" @click="placeOrder">
              <span v-if="placing">Оформлення...</span>
              <span v-else>Оформити замовлення</span>
            </button>

            <button v-if="user" @click="toggleHistory" class="btn-outline text-xs" type="button">
              {{ showHistory ? 'Сховати історію' : 'Показати історію' }}
            </button>
          </div>
        </div>

        <!-- Right: summary -->
        <div class="min-w-0">
          <div class="art-card lg:sticky lg:top-24">
            <div class="px-4 md:px-5 py-3 border-b border-[var(--color-line)] bg-[var(--color-surface-soft)]">
              <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)]">
                Підсумок
              </div>
            </div>

            <div class="p-4 md:p-5">
              <div class="space-y-2 min-h-[70px]">
                <div v-if="!chosen.length" class="text-sm text-[var(--color-text-muted)] italic">
                  Немає вибраних квитків
                </div>

                <div v-for="r in chosen" :key="r.id" class="flex justify-between items-start gap-4 text-sm">
                  <span class="text-[var(--color-text-soft)] leading-snug">
                    {{ r.name }} × {{ r.quantity }}
                  </span>
                  <span class="font-medium text-[var(--color-text)] whitespace-nowrap">
                    {{ fmt(r.sum) }}
                  </span>
                </div>
              </div>

              <div class="border-t border-[var(--color-line)] mt-4 pt-4 flex justify-between items-end gap-4">
                <span class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)]">
                  Разом
                </span>
                <span class="font-serif text-2xl md:text-[1.65rem] font-semibold text-[var(--color-text)] leading-none">
                  {{ fmt(total) }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="message" class="alert-success mt-6">
        {{ message }}
      </div>

      <img v-if="qr" :src="qr" alt="QR код замовлення"
        class="mt-4 w-36 h-36 border border-[var(--color-line)] bg-white p-2" />

      <!-- History -->
      <div v-if="showHistory" class="mt-10">
        <div class="flex items-end justify-between gap-4 mb-4">
          <h2>Історія ваших замовлень</h2>
        </div>

        <div class="art-card overflow-hidden">
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-[var(--color-surface-soft)]">
                <tr class="border-b border-[var(--color-line)]">
                  <th
                    class="text-left px-4 py-3 text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] font-medium">
                    Дата
                  </th>
                  <th
                    class="text-left px-4 py-3 text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] font-medium">
                    Виставка
                  </th>
                  <th
                    class="text-left px-4 py-3 text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] font-medium">
                    Категорія
                  </th>
                  <th
                    class="text-left px-4 py-3 text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] font-medium">
                    К-сть
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in history" :key="row.id"
                  class="border-b border-[color:rgba(49,91,125,0.18)] last:border-0 hover:bg-[var(--color-accent-soft)]/40 transition-colors">
                  <td class="px-4 py-3 text-[var(--color-text-soft)] whitespace-nowrap">
                    {{ fmtDate(row.createdAt) }}
                  </td>
                  <td class="px-4 py-3 text-[var(--color-text)] font-serif">
                    {{ row.exhibition?.title || '—' }}
                  </td>
                  <td class="px-4 py-3 text-[var(--color-text-soft)]">
                    {{ row.category?.name || '—' }}
                  </td>
                  <td class="px-4 py-3 text-[var(--color-text)] font-medium">
                    {{ row.quantity }}
                  </td>
                </tr>

                <tr v-if="!history.length">
                  <td colspan="4" class="px-4 py-7 text-sm text-[var(--color-text-muted)] text-center italic">
                    Історія порожня.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="!user" class="alert-info mt-8">
        Щоби оформити замовлення та переглядати історію,
        <span @click="placeOrder"
          class="font-medium ml-1 cursor-pointer text-[var(--color-accent)] hover:text-[var(--color-accent-hover)]">увійдіть</span>.
      </div>
    </template>
  </div>
</template>