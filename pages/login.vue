<script setup lang="ts">
import { ref, computed, watchEffect } from 'vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const route = useRoute()

const email = ref(''); const password = ref(''); const username = ref('')
const err = ref(''); const loading = ref(false)
const tab = ref<'signin' | 'signup'>('signin')

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const isValidEmail = computed(() => emailRegex.test(email.value))

const translateError = (msg: string) => {
  const text = msg?.toLowerCase() || ''
  if (text.includes('invalid login credentials')) return 'Невірна електронна адреса або пароль'
  if (text.includes('user already registered') || text.includes('email already registered') || text.includes('duplicate')) return 'Користувач з таким email вже існує'
  if (text.includes('password should be at least') || text.includes('signup requires a valid password')) return 'Пароль повинен містити щонайменше 6 символів'
  if (text.includes('email not confirmed')) return 'Електронна адреса ще не підтверджена. Перевірте пошту.'
  return msg
}

async function redirectByRole() {
  const { data, error } = await supabase.auth.getUser()
  if (error || !data?.user) { navigateTo('/'); return }
  const { data: profile } = await supabase.from('profiles').select('role').eq('id', data.user.id).maybeSingle()
  if (profile?.role === 'admin') navigateTo('/admin')
  else {
    const next = route.query.next
    if (typeof next === 'string' && next) return navigateTo(next)
    return navigateTo('/')
  }
}

watchEffect(() => {
  if (!user.value) return
  if (route.path === '/login' || route.path === '/login/') redirectByRole()
})

const signIn = async () => {
  err.value = ''
  if (!isValidEmail.value) { err.value = 'Введіть коректний email'; return }
  loading.value = true
  const { error } = await supabase.auth.signInWithPassword({ email: email.value, password: password.value })
  loading.value = false
  if (error) { err.value = translateError(error.message); return }
  await redirectByRole()
}

const signUp = async () => {
  err.value = ''
  if (!isValidEmail.value) { err.value = 'Введіть коректний email'; return }
  loading.value = true
  const uname = username.value.trim() || email.value.split('@')[0]
  const { data, error } = await supabase.auth.signUp({ email: email.value, password: password.value })
  loading.value = false
  if (error) { err.value = translateError(error.message); return }
  if (data?.user) await supabase.from('profiles').insert({ id: data.user.id, username: uname })
  await redirectByRole()
}
</script>

<template>
  <div class="min-h-screen bg-[var(--color-bg)] flex items-center justify-center px-4 py-10 md:py-14">
    <div class="w-full max-w-md">
      <!-- Logo -->
      <div class="text-center mb-8 md:mb-10">
        <NuxtLink to="/"
          class="font-serif text-[2rem] md:text-[2.25rem] font-semibold text-[var(--color-text)] tracking-[0.08em] hover:text-[var(--color-accent)] transition-colors">
          Art Gallery
        </NuxtLink>
        <div class="divider mx-auto mt-3"></div>
      </div>

      <div class="art-card bg-[var(--color-surface)]">
        <!-- Tabs -->
        <div class="flex border-b border-[var(--color-line)] bg-[var(--color-surface-soft)]">
          <button @click="tab = 'signin'"
            class="flex-1 px-4 py-4 text-[11px] tracking-[0.16em] uppercase transition-colors" :class="tab === 'signin'
              ? 'text-[var(--color-text)] border-b border-[var(--color-accent)] -mb-px font-medium bg-[var(--color-surface)]'
              : 'text-[var(--color-text-muted)] hover:text-[var(--color-text)]'">
            Увійти
          </button>

          <button @click="tab = 'signup'"
            class="flex-1 px-4 py-4 text-[11px] tracking-[0.16em] uppercase transition-colors" :class="tab === 'signup'
              ? 'text-[var(--color-text)] border-b border-[var(--color-accent)] -mb-px font-medium bg-[var(--color-surface)]'
              : 'text-[var(--color-text-muted)] hover:text-[var(--color-text)]'">
            Зареєструватися
          </button>
        </div>

        <!-- Sign In -->
        <div v-if="tab === 'signin'" class="p-6 md:p-8 space-y-5">
          <div class="mb-1">
            <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-4">
              Вхід до кабінету
            </div>
          </div>

          <div>
            <label class="field-label">Email</label>
            <input v-model="email" type="email" class="field-input" placeholder="your@email.com" />
          </div>

          <div>
            <label class="field-label">Пароль</label>
            <input v-model="password" type="password" class="field-input" placeholder="••••••••" />
          </div>

          <div v-if="err" class="alert-error">
            {{ err }}
          </div>

          <button :disabled="loading" @click="signIn" class="btn-primary text-xs w-full justify-center mt-2">
            <span v-if="loading">Зачекайте...</span>
            <span v-else>Увійти</span>
          </button>
        </div>

        <!-- Sign Up -->
        <div v-else class="p-6 md:p-8 space-y-5">
          <div class="mb-1">
            <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-4">
              Створення акаунта
            </div>
          </div>

          <div>
            <label class="field-label">Email</label>
            <input v-model="email" type="email" class="field-input" placeholder="your@email.com" />
          </div>

          <div>
            <label class="field-label">Ім'я</label>
            <input v-model="username" type="text" class="field-input" placeholder="Ваше ім'я" />
          </div>

          <div>
            <label class="field-label">Пароль</label>
            <input v-model="password" type="password" class="field-input" placeholder="••••••••" />
          </div>

          <div v-if="err" class="alert-error">
            {{ err }}
          </div>

          <button :disabled="loading" @click="signUp" class="btn-primary text-xs w-full justify-center mt-2">
            <span v-if="loading">Зачекайте...</span>
            <span v-else>Зареєструватися</span>
          </button>
        </div>
      </div>

      <div class="text-center mt-6">
        <NuxtLink to="/"
          class="text-[11px] uppercase tracking-[0.16em] text-[var(--color-text-muted)] hover:text-[var(--color-text)] transition-colors">
          ← На головну
        </NuxtLink>
      </div>
    </div>
  </div>
</template>