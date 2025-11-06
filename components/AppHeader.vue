<script setup lang="ts">
const route = useRoute()
const user = useSupabaseUser()
const supabase = useSupabaseClient()
const profile = ref<{ username?: string; role?: string } | null>(null)
const menu = ref(false)

const fetchProfile = async () => {
  if (!user.value) { profile.value = null; return }
  const { data, error } = await supabase
    .from('profiles')
    .select('username, role')
    .eq('id', user.value.id)
    .maybeSingle()
  if (!error) profile.value = data
}

onMounted(fetchProfile)
watch(user, () => fetchProfile())

const logout = async () => {
  await supabase.auth.signOut()
  profile.value = null
  navigateTo('/')
}

const isActive = (to: string) => {
  return route.path === to || route.path.startsWith(to + '/')
}

const go = (p: string) => navigateTo(p)
</script>

<template>
  <!-- Білий хедер поверх сірого фону сторінки; фіксований, із контейнером -->
  <v-app-bar app flat elevation="1" color="white" density="comfortable">
    <div class="container head">
      <div class="brand" @click="go('/')">Art Gallery</div>

      <nav class="nav">
        <!-- Навігація згідно зразка -->
        <NuxtLink :to="'/'" class="nav-link" :class="{ active: isActive('/') }">Головна</NuxtLink>
        <NuxtLink :to="'/exhibitions/current'"  class="nav-link" :class="{ active: isActive('/exhibitions/current') }">Поточна</NuxtLink>
        <NuxtLink :to="'/exhibitions/past'"     class="nav-link" :class="{ active: isActive('/exhibitions/past') }">Минулі</NuxtLink>
        <NuxtLink :to="'/exhibitions/upcoming'" class="nav-link" :class="{ active: isActive('/exhibitions/upcoming') }">Майбутні</NuxtLink>
        <NuxtLink :to="'/artists'"  class="nav-link" :class="{ active: isActive('/artists') }">Художники</NuxtLink>
        <NuxtLink :to="'/tickets'"  class="nav-link" :class="{ active: isActive('/tickets') }">Квитки</NuxtLink>
        <NuxtLink :to="'/contacts'" class="nav-link" :class="{ active: isActive('/contacts') }">Контакти</NuxtLink>
      </nav>

      <!-- Праворуч: логін/кабінет -->
      <div class="auth">
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
    </div>
  </v-app-bar>
</template>

<style scoped>
.head{
  display:flex;
  align-items:center;
  justify-content:space-between;
  min-height:64px;
  gap: 16px;
}
.brand{
  font-weight:700;
  letter-spacing:.2px;
  cursor:pointer;
}
.nav{
  display:flex;
  gap: 16px;
  align-items:center;
  flex-wrap: wrap;
}
.nav-link{
  text-decoration:none;
  color: inherit;
  opacity:.85;
  padding: 6px 10px;
  border-radius: 8px;
}
.nav-link:hover{ opacity:1; background: rgba(0,0,0,.04); }
.nav-link.active{ color: var(--brand); opacity:1; background: rgba(30,64,175,.08); }

.auth{
  display:flex; align-items:center;
}
</style>
