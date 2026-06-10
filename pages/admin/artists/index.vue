<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const items = ref<any[]>([])
const loading = ref(true)
const errorMsg = ref<string | null>(null)

const fetchArtists = async () => {
  loading.value = true
  const { data, error } = await supabase.from('artists').select('id,"fullName",country,birthYear,imageUrl').order('fullName')
  if (error) errorMsg.value = error.message
  items.value = data || []
  loading.value = false
}
onMounted(fetchArtists)
</script>

<template>
  <div>
    <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-7">
      <div>
        <div class="text-[11px] tracking-[0.14em] uppercase text-[var(--color-text-muted)] mb-2">
          Адмін-панель
        </div>
        <h1 class="font-serif text-[1.85rem] md:text-[2.05rem] font-semibold text-[var(--color-text)] leading-none">
          Художники
        </h1>
      </div>

      <NuxtLink to="/admin/artists/new" class="btn-primary self-start sm:self-auto">
        Додати художника
      </NuxtLink>
    </div>

    <div v-if="errorMsg" class="alert-error mb-6 max-w-2xl">{{ errorMsg }}</div>

    <div class="art-card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full min-w-[560px] table-fixed">
          <colgroup>
            <col style="width: 82px" />
            <col />
            <col style="width: 56px" />
          </colgroup>

          <thead class="bg-[var(--color-surface-soft)]">
            <tr class="border-b border-[var(--color-line)]">
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Фото
              </th>
              <th
                class="px-4 py-3 text-left text-[11px] tracking-[0.13em] uppercase text-[var(--color-text-muted)] font-medium">
                Художник
              </th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>

          <tbody>
            <tr v-if="loading">
              <td colspan="3" class="px-4 py-10 text-sm text-[var(--color-text-muted)] text-center">
                Завантаження...
              </td>
            </tr>

            <tr v-else-if="!items.length">
              <td colspan="3" class="px-4 py-10 text-sm text-[var(--color-text-muted)] text-center italic">
                Немає художників
              </td>
            </tr>

            <tr v-for="a in items" v-else :key="a.id"
              class="border-b border-[color:rgba(49,91,125,0.14)] last:border-0 cursor-pointer hover:bg-[var(--color-accent-faint)] transition-colors"
              @click="navigateTo('/admin/artists/' + a.id)">
              <td class="px-4 py-3 align-middle">
                <div class="w-[56px] h-[56px] shrink-0 overflow-hidden bg-[var(--color-surface-soft)]">
                  <img v-if="a.imageUrl" :src="a.imageUrl" class="w-full h-full object-cover"
                    :alt="a.fullName || 'Художник'" />
                  <div v-else
                    class="w-full h-full flex items-center justify-center font-serif text-xl text-[var(--color-text-muted)]/45">
                    {{ a.fullName?.[0] }}
                  </div>
                </div>
              </td>

              <td class="px-4 py-3 align-middle">
                <div class="font-medium text-[var(--color-text)] truncate">
                  {{ a.fullName }}
                </div>
              </td>

              <td class="px-4 py-3 align-middle text-right">
                <svg class="w-4 h-4 ml-auto text-[var(--color-text-muted)] opacity-70" fill="none" viewBox="0 0 24 24"
                  stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5l7 7-7 7" />
                </svg>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>