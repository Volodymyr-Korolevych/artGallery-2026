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
    <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-7">
      <div>
        <div class="text-[11px] tracking-[0.14em] uppercase text-[var(--color-text-muted)] mb-2">
          Адмін-панель
        </div>
        <h1 class="font-serif text-[1.85rem] md:text-[2.05rem] font-semibold text-[var(--color-text)] leading-none">
          Відгуки та повідомлення
        </h1>
      </div>

      <span class="text-[11px] tracking-[0.12em] uppercase text-[var(--color-text-muted)] self-start sm:self-auto">
        {{ items.length }} записів
      </span>
    </div>

    <div v-if="errorMsg" class="alert-error mb-6 max-w-2xl">
      {{ errorMsg }}
    </div>

    <div class="art-card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full min-w-[920px] table-fixed">
          <colgroup>
            <col style="width: 72px" />
            <col style="width: 170px" />
            <col style="width: 230px" />
            <col />
            <col style="width: 170px" />
          </colgroup>

          <thead class="bg-[var(--color-surface-soft)]">
            <tr class="border-b border-[var(--color-line)]">
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                ID
              </th>
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Ім'я
              </th>
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Email
              </th>
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Повідомлення
              </th>
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Дата
              </th>
            </tr>
          </thead>

          <tbody>
            <tr v-for="r in items" :key="r.id"
              class="border-b border-[color:rgba(49,91,125,0.14)] last:border-0 align-top hover:bg-[var(--color-accent-faint)] transition-colors">
              <td class="px-4 py-3 text-[var(--color-text-muted)]">
                {{ r.id }}
              </td>

              <td class="px-4 py-3 font-medium text-[var(--color-text)]">
                {{ r.name }}
              </td>

              <td class="px-4 py-3 text-[var(--color-text-soft)] break-words">
                {{ r.email }}
              </td>

              <td class="px-4 py-3 text-[var(--color-text-soft)] whitespace-pre-wrap leading-[1.45]">
                {{ r.message }}
              </td>

              <td class="px-4 py-3 text-[var(--color-text-muted)] text-xs whitespace-nowrap">
                {{ fmtDate(r.createdAt) }}
              </td>
            </tr>

            <tr v-if="!loading && !items.length">
              <td colspan="5" class="px-4 py-10 text-sm text-[var(--color-text-muted)] text-center italic">
                Поки немає відгуків
              </td>
            </tr>

            <tr v-if="loading">
              <td colspan="5" class="px-4 py-10 text-sm text-[var(--color-text-muted)] text-center">
                Завантаження...
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>