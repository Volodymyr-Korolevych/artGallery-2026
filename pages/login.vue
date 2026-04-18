<script setup lang="ts">
import { ref, computed, watchEffect } from 'vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const route = useRoute()

const email = ref(''); const password = ref(''); const username = ref('')
const err = ref(''); const loading = ref(false)
const tab = ref<'signin'|'signup'>('signin')

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
  <div class="min-h-screen bg-stone-50 flex items-center justify-center px-4">
    <div class="w-full max-w-md">
      <!-- Logo -->
      <div class="text-center mb-10">
        <NuxtLink to="/" class="font-serif text-3xl font-semibold text-neutral-900 tracking-wider">
          Art Gallery
        </NuxtLink>
        <div class="divider mx-auto mt-3"></div>
      </div>

      <div class="bg-white border border-neutral-100 p-8 lg:p-10">
        <!-- Tabs -->
        <div class="flex gap-0 border-b border-neutral-100 mb-8">
          <button
            @click="tab = 'signin'"
            class="flex-1 pb-3 text-xs tracking-widest uppercase transition-colors"
            :class="tab === 'signin' ? 'text-neutral-900 border-b-2 border-neutral-900 -mb-px font-medium' : 'text-neutral-400 hover:text-neutral-600'"
          >Увійти</button>
          <button
            @click="tab = 'signup'"
            class="flex-1 pb-3 text-xs tracking-widest uppercase transition-colors"
            :class="tab === 'signup' ? 'text-neutral-900 border-b-2 border-neutral-900 -mb-px font-medium' : 'text-neutral-400 hover:text-neutral-600'"
          >Зареєструватися</button>
        </div>

        <!-- Sign In -->
        <div v-if="tab === 'signin'" class="space-y-5">
          <div>
            <label class="field-label">Email</label>
            <input v-model="email" type="email" class="field-input" placeholder="your@email.com" />
          </div>
          <div>
            <label class="field-label">Пароль</label>
            <input v-model="password" type="password" class="field-input" placeholder="••••••••" />
          </div>
          <div v-if="err" class="alert-error">{{ err }}</div>
          <button :disabled="loading" @click="signIn" class="btn-primary text-xs w-full justify-center mt-2">
            <span v-if="loading">Зачекайте...</span>
            <span v-else>Увійти</span>
          </button>
        </div>

        <!-- Sign Up -->
        <div v-else class="space-y-5">
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
          <div v-if="err" class="alert-error">{{ err }}</div>
          <button :disabled="loading" @click="signUp" class="btn-primary text-xs w-full justify-center mt-2">
            <span v-if="loading">Зачекайте...</span>
            <span v-else>Зареєструватися</span>
          </button>
        </div>
      </div>

      <div class="text-center mt-6">
        <NuxtLink to="/" class="text-xs text-neutral-400 hover:text-neutral-600 transition-colors tracking-wider uppercase">
          ← На головну
        </NuxtLink>
      </div>
    </div>
  </div>
</template>
