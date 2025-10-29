<script setup lang="ts">
const user = useSupabaseUser()
const supabase = useSupabaseClient()
const profile = ref<{ username?: string, role?: string } | null>(null)
const menu = ref(false)

const fetchProfile = async () => {
  if (!user.value) { profile.value = null; return }
  const { data, error } = await supabase.from('profiles').select('username, role').eq('id', user.value.id).maybeSingle()
  if (!error) profile.value = data
}

onMounted(fetchProfile)
watch(user, () => fetchProfile())

const logout = async () => {
  await supabase.auth.signOut()
  profile.value = null
  navigateTo('/')
}
</script>

<template>
  <v-app-bar color="primary" density="comfortable" flat>
    <v-toolbar-title class="font-weight-bold">Art Gallery</v-toolbar-title>
    <v-spacer />
    <v-btn variant="text" to="/">Головна</v-btn>
    <v-btn variant="text" to="/exhibitions/current">Поточна</v-btn>
    <v-btn variant="text" to="/exhibitions/past">Минулі</v-btn>
    <v-btn variant="text" to="/exhibitions/upcoming">Майбутні</v-btn>
    <v-btn variant="text" to="/artists">Художники</v-btn>
    <v-btn variant="text" to="/tickets">Квитки</v-btn>
    <v-btn variant="text" to="/contacts">Контакти</v-btn>

    <div class="ml-2">
      <template v-if="!user">
        <v-btn color="secondary" to="/login">Увійти</v-btn>
      </template>
      <template v-else>
        <v-menu v-model="menu" :close-on-content-click="true" location="bottom">
          <template #activator="{ props }">
            <v-btn v-bind="props" color="secondary">
              {{ profile?.username || 'Кабінет' }}
            </v-btn>
          </template>
          <v-list>
            <v-list-item v-if="profile?.role==='admin'" to="/admin">Адмін-панель</v-list-item>
            <v-list-item @click="logout">Вийти</v-list-item>
          </v-list>
        </v-menu>
      </template>
    </div>
  </v-app-bar>
</template>
