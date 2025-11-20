<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
const supabase = useSupabaseClient()

const items = ref<any[]>([])
const loading = ref(true)
const errorMsg = ref<string|null>(null)

const fetchArtists = async () => {
  loading.value = true
  const { data, error } = await supabase
    .from('artists')
    .select('id,"fullName",country,birthYear,imageUrl')
    .order('fullName')
  if (error) errorMsg.value = error.message
  items.value = data || []
  loading.value = false
}

onMounted(fetchArtists)

const goNew = () => navigateTo('/admin/artists/new')
const open = (id:number) => navigateTo(`/admin/artists/${id}`)
</script>

<template>
  <div class="page">
    <div class="head">
      <h1 class="text-h5">Художники</h1>
      <v-btn color="primary" @click="goNew">Додати</v-btn>
    </div>

    <v-alert v-if="errorMsg" type="error" density="compact" class="mb-3">{{ errorMsg }}</v-alert>

    <v-card>
      <v-table id="artists-t">

        <tbody>
          <tr v-for="a in items" :key="a.id" class="mx-4 row" @click="open(a.id)">
            <td style="width:100px;">
              <v-img v-if="a.imageUrl" :src="a.imageUrl" height="100" contain class="rounded img-auto" />
            </td>
            <td>{{ a.fullName }}</td>
            <td>{{ a.country || '—' }}</td>
            <td>{{ a.birthYear || '—' }}</td>
          </tr>
          <tr v-if="!loading && items.length===0">
            <td colspan="4" class="muted">Поки немає записів</td>
          </tr>
        </tbody>
      </v-table>
    </v-card>
  </div>
</template>

<style>
#artists-t table {
  border-spacing: 20px !important;
}
#artists-t td {
  border-color: transparent !important;
}
.page { display: grid; gap: 12px; }
.head { display:flex; align-items:center; justify-content:space-between; }
.row { cursor: pointer; }
.row:hover { background: rgba(0,0,0,.03); }
.img-auto { width: auto; }
.muted { color: rgba(0,0,0,.5); text-align:center; padding: 16px; }
</style>
