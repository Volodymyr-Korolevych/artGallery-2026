<script setup lang="ts">
const route = useRoute()
const user = useSupabaseUser()
const supabase = useSupabaseClient()
const profile = ref < { username?: string; role?: string } | null > (null)
const menuOpen = ref(false)
const mobileOpen = ref(false)

const fetchProfile = async (retries = 3) => {
  if (!user.value) { profile.value = null; return }
  for (let i = 0; i < retries; i++) {
    const { data, error } = await supabase
      .from('profiles').select('username, role').eq('id', user.value.id).maybeSingle()
    if (!error && data) { profile.value = data; return }
    await new Promise(r => setTimeout(r, 300))
  }
  profile.value = null
}

onMounted(() => {
  fetchProfile()
  document.addEventListener('click', handleOutsideClick)
})
onUnmounted(() => {
  document.removeEventListener('click', handleOutsideClick)
})

const menuRef = ref < HTMLElement | null > (null)
const handleOutsideClick = (e: MouseEvent) => {
  if (menuRef.value && !menuRef.value.contains(e.target as Node)) {
    menuOpen.value = false
  }
}

watch(user, () => fetchProfile())

const logout = async () => {
  if (typeof window !== 'undefined') {
    localStorage.removeItem('ticketsDraft_v1')
  }
  await supabase.auth.signOut()
  profile.value = null
  menuOpen.value = false
  navigateTo('/')
}

const isActive = (to: string) => route.path === to || route.path.startsWith(to + '/')

const navLinks = [
  { to: '/about', label: 'Про нас' },
  { to: '/exhibitions', label: 'Виставки' },
  { to: '/tickets', label: 'Придбати квитки' },
  { to: '/contacts', label: 'Контакти' },
]
</script>

<template>
  <header
    class="sticky top-0 z-50 border-b border-[var(--color-line)] bg-[color:rgba(247,246,243,0.94)] backdrop-blur-sm">
    <div class="container">
      <div class="flex items-center justify-between h-16 lg:h-[72px]">

        <!-- Лого -->
        <NuxtLink to="/"
          class="font-serif text-xl md:text-[1.35rem] font-semibold tracking-[0.08em] text-[var(--color-text)] hover:text-[var(--color-accent)] transition-colors">
          Art Gallery
        </NuxtLink>

        <!-- Desktop Nav -->
        <nav class="hidden lg:flex items-center gap-1">
          <NuxtLink v-for="link in navLinks" :key="link.to" :to="link.to"
            class="px-4 py-2 text-[12px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] hover:text-[var(--color-text)] transition-colors relative after:absolute after:left-4 after:right-4 after:-bottom-[1px] after:h-px after:bg-[var(--color-accent)] after:scale-x-0 after:transition-transform after:duration-200"
            :class="{ '!text-[var(--color-text)] after:!scale-x-100 font-medium': isActive(link.to) }">
            {{ link.label }}
          </NuxtLink>
        </nav>

        <!-- Auth -->
        <div class="hidden lg:flex items-center">
          <template v-if="!user">
            <NuxtLink to="/login" class="btn-outline text-xs px-5 py-2">
              Увійти
            </NuxtLink>
          </template>

          <template v-else>
            <div class="relative" ref="menuRef">
              <button @click="menuOpen = !menuOpen"
                class="flex items-center gap-2 text-sm text-[var(--color-text-soft)] hover:text-[var(--color-text)] transition-colors px-3 py-2">
                <span
                  class="w-8 h-8 rounded-full flex items-center justify-center text-xs font-medium text-white bg-[var(--color-accent)]">
                  {{ (profile?.username || 'U')[0].toUpperCase() }}
                </span>
                <span>{{ profile?.username || 'Кабінет' }}</span>
                <svg class="w-3.5 h-3.5 transition-transform" :class="{ 'rotate-180': menuOpen }" viewBox="0 0 12 12"
                  fill="none">
                  <path d="M2 4l4 4 4-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
                </svg>
              </button>

              <!-- Dropdown -->
              <div v-if="menuOpen"
                class="absolute right-0 top-full mt-2 w-48 bg-[var(--color-surface)] border border-[var(--color-line)] shadow-[var(--shadow-soft)] py-1">
                <NuxtLink v-if="profile?.role === 'admin'" to="/admin"
                  class="block px-4 py-2.5 text-sm text-[var(--color-text-soft)] hover:bg-[var(--color-accent-soft)] hover:text-[var(--color-text)] transition-colors"
                  @click="menuOpen = false">
                  Адмін-панель
                </NuxtLink>

                <button @click="logout"
                  class="w-full text-left px-4 py-2.5 text-sm text-[var(--color-text-soft)] hover:bg-[var(--color-accent-soft)] hover:text-[var(--color-text)] transition-colors">
                  Вийти
                </button>
              </div>
            </div>
          </template>
        </div>

        <!-- Mobile burger -->
        <button class="lg:hidden p-2 text-[var(--color-text-soft)] hover:text-[var(--color-text)] transition-colors"
          @click="mobileOpen = !mobileOpen" aria-label="Відкрити меню">
          <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path v-if="!mobileOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
              d="M4 6h16M4 12h16M4 18h16" />
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>

    <!-- Mobile menu -->
    <div v-if="mobileOpen" class="lg:hidden bg-[var(--color-surface)] border-t border-[var(--color-line)] py-4">
      <div class="container space-y-1">
        <NuxtLink v-for="link in navLinks" :key="link.to" :to="link.to"
          class="block py-3 text-[13px] tracking-[0.12em] uppercase text-[var(--color-text-soft)] hover:text-[var(--color-text)] border-b border-[color:rgba(188,194,200,0.25)] last:border-0 transition-colors"
          :class="{ '!text-[var(--color-text)] font-medium': isActive(link.to) }" @click="mobileOpen = false">
          {{ link.label }}
        </NuxtLink>

        <div class="pt-3">
          <NuxtLink v-if="!user" to="/login" class="btn-primary text-xs w-full justify-center"
            @click="mobileOpen = false">
            Увійти
          </NuxtLink>

          <button v-else @click="logout" class="btn-ghost text-xs w-full justify-start pl-0">
            Вийти ({{ profile?.username }})
          </button>
        </div>
      </div>
    </div>
  </header>
</template>