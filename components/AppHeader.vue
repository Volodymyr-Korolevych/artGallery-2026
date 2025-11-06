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
  <v-app-bar app flat elevation="1" color="white" density="comfortable">
    <div class="container head">
      <!-- ЛОГО → Головна -->
      <div class="brand" @click="go('/')">
        Art Gallery
      </div>

      <!-- Головне меню згідно ТЗ -->
      <nav class="nav">
        <NuxtLink to="/about"       class="nav-link" :class="{ active: isActive('/about') }">Про нас</NuxtLink>
        <NuxtLink to="/exhibitions" class="nav-link" :class="{ active: isActive('/exhibitions') }">Виставки</NuxtLink>
        <NuxtLink to="/tickets"     class="nav-link" :class="{ active: isActive('/tickets') }">Придбати квитки</NuxtLink>
        <NuxtLink to="/contacts"    class="nav-link" :class="{ active: isActive('/contacts') }">Контакти</NuxtLink>
      </nav>

      <!-- Логін / Кабінет -->
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
.head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  min-height: 64px;
}
.brand {
  font-weight: 700;
  cursor: pointer;
  letter-spacing: .2px;
}
.nav {
  display: flex;
  gap: 16px;
  align-items: center;
  flex-wrap: wrap;
}
.nav-link {
  padding: 6px 10px;
  border-radius: 8px;
  text-decoration: none;
  opacity: .85;
  color: inherit;
}
.nav-link:hover {
  opacity: 1;
  background: rgba(0,0,0,.05);
}
.nav-link.active {
  opacity: 1;
  background: rgba(30,64,175,.10);
  color: var(--brand);
}
.auth {
  display: flex;
  align-items: center;
}
</style>
