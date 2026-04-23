<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const loading = ref(true); const errorMsg = ref<string | null>(null)
const items = ref<Record<string, any>[]>([])

const fetchAll = async () => {
  loading.value = true; errorMsg.value = null
  const { data, error } = await supabase.from('contact_messages').select('id,"name","email","message","createdAt"').order('createdAt', { ascending: false })
  if (error) errorMsg.value = error.message
  items.value = data || []
  loading.value = false
}
onMounted(fetchAll)

const fmtDate = (v: any) => {
  if (!v) return '—'
  try { return new Date(v).toLocaleString('uk-UA') } catch { return String(v) }
}
</script>

<template>
  <div>
    <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-8">
      <div>
        <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-2">
          Адмін-панель
        </div>
        <h1 class="font-serif text-[2rem] md:text-[2.25rem] font-semibold text-[var(--color-text)] leading-none">
          Відгуки та повідомлення
        </h1>
      </div>

      <span class="text-xs tracking-[0.12em] uppercase text-[var(--color-text-muted)] self-start sm:self-auto">
        {{ items.length }} записів
      </span>
    </div>

    <div v-if="errorMsg" class="alert-error mb-6 max-w-2xl">
      {{ errorMsg }}
    </div>

    <div class="art-card overflow-hidden">
      <div class="px-5 md:px-6 py-4 border-b border-[var(--color-line)] bg-[var(--color-surface-soft)]">
        <div
          class="grid grid-cols-[72px_160px_220px_minmax(0,1fr)_170px] gap-4 items-center text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)]">
          <div>ID</div>
          <div>Ім'я</div>
          <div>Email</div>
          <div>Повідомлення</div>
          <div>Дата</div>
        </div>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full min-w-[920px] text-sm">
          <tbody>
            <tr v-for="r in items" :key="r.id"
              class="border-b border-[color:rgba(188,197,203,0.25)] last:border-0 align-top hover:bg-[var(--color-accent-soft)]/40 transition-colors">
              <td class="px-5 py-4 text-[var(--color-text-muted)] w-[72px]">
                {{ r.id }}
              </td>

              <td class="px-5 py-4 font-medium text-[var(--color-text)] w-[160px]">
                {{ r.name }}
              </td>

              <td class="px-5 py-4 text-[var(--color-text-soft)] w-[220px] break-words">
                {{ r.email }}
              </td>

              <td class="px-5 py-4 text-[var(--color-text-soft)] max-w-xl whitespace-pre-wrap leading-relaxed">
                {{ r.message }}
              </td>

              <td class="px-5 py-4 text-[var(--color-text-muted)] text-xs w-[170px] whitespace-nowrap">
                {{ fmtDate(r.createdAt) }}
              </td>
            </tr>

            <tr v-if="!loading && !items.length">
              <td colspan="5" class="px-5 py-12 text-sm text-[var(--color-text-muted)] text-center italic">
                Поки немає відгуків
              </td>
            </tr>

            <tr v-if="loading">
              <td colspan="5" class="px-5 py-12 text-sm text-[var(--color-text-muted)] text-center">
                Завантаження...
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>