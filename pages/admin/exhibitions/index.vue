<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

type Exhibition = { id: number; title: string; painterId: number | null; coverUrl?: string | null; cardUrl?: string | null; startDate?: string | null; endDate?: string | null; isPublished?: boolean; status?: string }

const items = ref<Exhibition[]>([])
const artistsById = ref<Record<number, string>>({})
const fmtUA = (v: string | null | undefined) => v ? new Date(v).toLocaleDateString('uk-UA') : '—'

const fetchAll = async () => {
  const { data: exhs } = await supabase.from('exhibitions').select('*').order('createdAt', { ascending: false })
  items.value = exhs || []
  const { data: artists } = await supabase.from('artists').select('id,"fullName"')
  artistsById.value = {}
  for (const a of (artists || [])) artistsById.value[a.id] = a.fullName
}
onMounted(fetchAll)
</script>

<template>
  <div>
    <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-7">
      <div>
        <div class="text-[11px] tracking-[0.14em] uppercase text-[var(--color-text-muted)] mb-2">
          Адмін-панель
        </div>
        <h1 class="font-serif text-[1.85rem] md:text-[2.05rem] font-semibold text-[var(--color-text)] leading-none">
          Експозиції
        </h1>
      </div>

      <NuxtLink to="/admin/exhibitions/new" class="btn-primary self-start sm:self-auto">
        Додати виставку
      </NuxtLink>
    </div>

    <div class="art-card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full min-w-[760px] table-fixed">
          <colgroup>
            <col style="width: 104px" />
            <col />
            <col style="width: 150px" />
          </colgroup>

          <thead class="bg-[var(--color-surface-soft)]">
            <tr class="border-b border-[var(--color-line)]">
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Зображення
              </th>
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Експозиція
              </th>
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Статус
              </th>
            </tr>
          </thead>

          <tbody>
            <tr v-for="e in items" :key="e.id"
              class="border-b border-[color:rgba(49,91,125,0.14)] last:border-0 cursor-pointer hover:bg-[var(--color-accent-faint)] transition-colors"
              @click="navigateTo('/admin/exhibitions/' + e.id)">
              <td class="px-4 py-3 align-middle">
                <div class="w-[76px] h-[54px] shrink-0 overflow-hidden bg-[var(--color-surface-soft)]">
                  <img v-if="e.cardUrl" :src="e.cardUrl" class="w-full h-full object-cover"
                    :alt="e.title || 'Експозиція'" />
                  <div v-else
                    class="w-full h-full flex items-center justify-center text-[var(--color-text-muted)] text-xs">
                    —
                  </div>
                </div>
              </td>

              <td class="px-4 py-3 align-middle">
                <div class="font-medium text-[var(--color-text)] truncate mb-1">
                  {{ e.title || 'Без назви' }}
                </div>

                <div class="text-sm text-[var(--color-text-soft)] truncate">
                  {{ artistsById[e.painterId || (-1 as any)] || '—' }}
                </div>

                <div class="text-[11px] text-[var(--color-text-muted)] mt-1">
                  {{ fmtUA(e.startDate) }} — {{ fmtUA(e.endDate) }}
                </div>
              </td>

              <td class="px-4 py-3 align-middle">
                <span v-if="e.isPublished" class="status-badge current">
                  Опубліковано
                </span>
                <span v-else class="status-badge past">
                  Чернетка
                </span>
              </td>
            </tr>

            <tr v-if="!items.length">
              <td colspan="3" class="px-4 py-10 text-sm text-[var(--color-text-muted)] text-center italic">
                Немає виставок
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>