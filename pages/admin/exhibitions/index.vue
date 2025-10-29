<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

type Exhibition = {
  id: number
  title: string
  painterId: number | null
  coverUrl?: string | null
  cardUrl?: string | null
  startDate?: string | null
  endDate?: string | null
  isPublished?: boolean
}

const items = ref<Exhibition[]>([])
const artistsById = ref<Record<number, string>>({})

const fmtUA = (v: string | null | undefined) => v ? new Date(v).toLocaleDateString('uk-UA') : '—'

const fetchAll = async () => {
  const { data: exhs } = await supabase.from('exhibitions').select('*').order('createdAt', { ascending: false })
  items.value = exhs || []

  const { data: artists } = await supabase.from('artists').select('id, "fullName"')
  artistsById.value = {}
  for (const a of (artists || [])) artistsById.value[a.id] = a.fullName
}

onMounted(fetchAll)

const thumb = (url?: string | null) => {
  if (!url) return 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="80" height="50"><rect width="100%" height="100%" fill="%23ddd"/></svg>'
  const sep = url.includes('?') ? '&' : '?'
  return url + sep + 'v=' + Date.now()
}

const openEdit = (id: number) => navigateTo('/admin/exhibitions/' + id)
const addNew   = () => navigateTo('/admin/exhibitions/new')
</script>

<template>
  <div class="exh-head">
    <h1 class="text-h5">Експозиції</h1>
    <v-btn color="primary" @click="addNew">Додати виставку</v-btn>
  </div>

  <v-card variant="flat" class="exh-block">
    <v-list lines="two" density="comfortable">
      <v-list-item
        v-for="e in items"
        :key="e.id"
        @click="openEdit(e.id)"
        class="exh-row"
      >
        <template #prepend>
          <v-img :src="thumb(e.cardUrl)" width="80" height="50" cover class="rounded-lg mr-3" />
        </template>

        <div class="d-flex flex-column">
          <div class="text-subtitle-1">{{ e.title || 'Без назви' }}</div>
          <div class="text-caption text-medium-emphasis">
            {{ artistsById[e.painterId || -1] || '—' }} ·
            {{ fmtUA(e.startDate) }} — {{ fmtUA(e.endDate) }}
            <span v-if="e.isPublished" class="ml-2">· Опубліковано</span>
          </div>
        </div>

        <template #append>
          <v-icon v-if="e.isPublished" icon="mdi-check-circle" class="text-success" />
          <v-icon v-else icon="mdi-circle-medium" class="text-disabled" />
        </template>
      </v-list-item>
    </v-list>
  </v-card>
</template>

<style scoped>
.exh-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}
.exh-row { cursor: pointer; }
.exh-block { width: 100%; max-width: none; }
</style>
