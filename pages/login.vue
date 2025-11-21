<script setup lang="ts">
import { ref, computed, watchEffect } from 'vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const route = useRoute()

const email = ref('')
const password = ref('')
const username = ref('')

const err = ref('')
const loading = ref(false)
const tab = ref<'signin' | 'signup'>('signin')

// Регулярний вираз для перевірки email
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const isValidEmail = computed(() => emailRegex.test(email.value))

// Переклад типових помилок Supabase українською
const translateError = (msg: string) => {
  const text = msg?.toLowerCase() || ''

  if (text.includes('invalid login credentials')) {
    return 'Невірна електронна адреса або пароль'
  }

  if (text.includes('user already registered') || text.includes('email already registered') || text.includes('duplicate')) {
    return 'Користувач з таким email вже існує'
  }

  if (text.includes('password should be at least') || text.includes('password must be at least') || text.includes('signup requires a valid password')) {
    return 'Пароль повинен містити щонайменше 6 символів'
  }

  if (text.includes('email not confirmed')) {
    return 'Електронна адреса ще не підтверджена. Перевірте пошту.'
  }

  // fallback — оригінальний текст
  return msg
}

// Допоміжна функція: визначити роль і перейти куди треба
async function redirectByRole() {
  const { data, error } = await supabase.auth.getUser()
  if (error || !data?.user) {
    // якщо з якоїсь причини користувача немає — просто на головну
    navigateTo('/')
    return
  }

  const { data: profile } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', data.user.id)
    .maybeSingle()

  if (profile?.role === 'admin') {
    navigateTo('/admin')
  } else {
    navigateTo('/')
  }
}

// Якщо користувач уже залогінений і відкрив /login — теж перенаправляємо його за роллю
watchEffect(() => {
  if (!user.value) return
  if (route.path === '/login' || route.path === '/login/') {
    redirectByRole()
  }
})

const signIn = async () => {
  err.value = ''

  if (!isValidEmail.value) {
    err.value = 'Введіть коректний email'
    return
  }

  loading.value = true
  const { error } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value
  })
  loading.value = false

  if (error) {
    err.value = translateError(error.message)
    return
  }

  // успішний логін — перевіряємо роль і робимо редирект
  await redirectByRole()
}

const signUp = async () => {
  err.value = ''

  if (!isValidEmail.value) {
    err.value = 'Введіть коректний email'
    return
  }

  loading.value = true
  const uname = username.value.trim() || email.value.split('@')[0]

  const { data, error } = await supabase.auth.signUp({
    email: email.value,
    password: password.value
  })

  loading.value = false

  if (error) {
    err.value = translateError(error.message)
    return
  }

  if (data?.user) {
    await supabase.from('profiles').insert({
      id: data.user.id,
      username: uname
      // роль, якщо треба, можна задати окремо у сидінгу / адмінці
    })
  }

  // після реєстрації — теж дивимось роль (на випадок, якщо це адмін)
  await redirectByRole()
}
</script>

<template>
  <div class="max-w-600 mx-auto py-8">
    <v-card class="pa-6">
      <v-tabs v-model="tab" class="mb-4">
        <v-tab value="signin">Увійти</v-tab>
        <v-tab value="signup">Зареєструватися</v-tab>
      </v-tabs>

      <div v-if="tab === 'signin'">
        <v-text-field v-model="email" label="Email" type="email" />
        <v-text-field v-model="password" label="Пароль" type="password" />

        <v-alert v-if="err" type="error" :text="err" class="mb-2" />

        <v-btn :loading="loading" color="primary" @click="signIn">
          Увійти
        </v-btn>
      </div>

      <div v-else>
        <v-text-field v-model="email" label="Email" type="email" />
        <v-text-field v-model="username" label="Ім'я" />
        <v-text-field v-model="password" label="Пароль" type="password" />

        <v-alert v-if="err" type="error" :text="err" class="mb-2" />

        <v-btn :loading="loading" color="primary" @click="signUp">
          Зареєструватися
        </v-btn>
      </div>
    </v-card>
  </div>
</template>
