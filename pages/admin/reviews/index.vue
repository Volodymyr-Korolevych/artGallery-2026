<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const loading = ref(true); const errorMsg = ref<string|null>(null)
const items = ref<Record<string,any>[]>([])

const fetchAll = async () => {
  loading.value = true; errorMsg.value = null
  const { data, error } = await supabase.from('contact_messages').select('id,"name","email","message","createdAt"').order('createdAt',{ascending:false})
  if (error) errorMsg.value = error.message
  items.value = data || []
  loading.value = false
}
onMounted(fetchAll)

const fmtDate = (v:any) => {
  if (!v) return '—'
  try { return new Date(v).toLocaleString('uk-UA') } catch { return String(v) }
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="font-serif text-2xl font-semibold text-neutral-900">Відгуки та повідомлення</h1>
      <span class="text-xs text-neutral-400">{{ items.length }} записів</span>
    </div>

    <div v-if="errorMsg" class="alert-error mb-4">{{ errorMsg }}</div>

    <div class="bg-white border border-neutral-100 overflow-hidden">
      <table class="w-full text-sm">
        <thead>
          <tr class="border-b border-neutral-100">
            <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium w-16">ID</th>
            <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium w-40">Ім'я</th>
            <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium w-52">Email</th>
            <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium">Повідомлення</th>
            <th class="text-left px-5 py-3 text-xs tracking-widest uppercase text-neutral-400 font-medium w-44">Дата</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in items" :key="r.id" class="border-b border-neutral-50 last:border-0 align-top hover:bg-neutral-50 transition-colors">
            <td class="px-5 py-4 text-neutral-400">{{ r.id }}</td>
            <td class="px-5 py-4 font-medium text-neutral-900">{{ r.name }}</td>
            <td class="px-5 py-4 text-neutral-600">{{ r.email }}</td>
            <td class="px-5 py-4 text-neutral-600 max-w-md whitespace-pre-wrap leading-relaxed">{{ r.message }}</td>
            <td class="px-5 py-4 text-neutral-400 text-xs">{{ fmtDate(r.createdAt) }}</td>
          </tr>
          <tr v-if="!loading && !items.length">
            <td colspan="5" class="px-5 py-10 text-sm text-neutral-400 text-center italic">Поки немає відгуків</td>
          </tr>
          <tr v-if="loading">
            <td colspan="5" class="px-5 py-10 text-sm text-neutral-400 text-center">Завантаження...</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
