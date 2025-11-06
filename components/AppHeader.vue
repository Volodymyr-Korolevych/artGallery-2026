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
                  <NuxtLink :to="\x27/about\x27" class="nav-link" :class="{ active: isActive(\x27/about\x27) }">Про нас</NuxtLink>
                  <NuxtLink :to="\x27/exhibitions\x27" class="nav-link" :class="{ active: isActive(\x27/exhibitions\x27) }">Виставки</NuxtLink>
                  <NuxtLink :to="\x27/tickets\x27" class="nav-link" :class="{ active: isActive(\x27/tickets\x27) }">Придбати квитки</NuxtLink>
                  <NuxtLink :to="\x27/contacts\x27" class="nav-link" :class="{ active: isActive(\x27/contacts\x27) }">Контакти</NuxtLink>
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
