<script setup lang="ts">
import { ref, computed, watchEffect } from 'vue'
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const email = ref('')
const password = ref('')
const username = ref('')

const err = ref('')
const loading = ref(false)
const tab = ref<'signin' | 'signup'>('signin')

// Перенаправлення на головну, якщо користувач уже залогінений
watchEffect(() => {
  if (user.value) {
    navigateTo('/')
  }
})

// Регулярний вираз для перевірки email
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const isValidEmail = computed(() => emailRegex.test(email.value))

// Переклад типових повідомлень Supabase українською
const translateError = (msg: string) => {
  const text = msg?.toLowerCase() || ''
  if (text.includes('invalid login credentials')) {
    return 'Невірна електронна адреса або пароль'
  } else if (text.includes('user already registered') || text.includes('email already registered') || text.includes('duplicate')) {
    return 'Користувач з таким email вже існує'
  } else if (text.includes('password should be at least') || text.includes('password must be at least')
  || text.includes('signup requires a valid password')) {
    return 'Пароль повинен містити щонайменше 6 символів'
  } else {
    // fallback: повернути оригінальне повідомлення
    return msg
  }
}

const signIn = async () => {
  err.value = ''
  // Валідність email
  if (!isValidEmail.value) {
    err.value = 'Введіть коректний email'
    return
  }
  loading.value = true
  const { error } = await supabase.auth.signInWithPassword({ email: email.value, password: password.value })
  loading.value = false
  if (error) {
    // переклад помилки
    err.value = translateError(error.message)
    return
  }
  navigateTo('/')
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
    password: password.value,
  })
  loading.value = false
  console.log('signUp data:', data)
  if (error) {
    err.value = translateError(error.message)
    return
  } else if (data?.user) {
    await supabase.from('profiles').insert({
      id: data.user.id,
      username: uname,
    })
  }
  navigateTo('/')
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
        <!-- Українське повідомлення про помилку -->
        <v-alert v-if="err" type="error" :text="err" class="mb-2" />
        <v-btn :loading="loading" color="primary" @click="signIn">Увійти</v-btn>
      </div>

      <div v-else>
        <v-text-field v-model="email" label="Email" type="email" />
        <v-text-field v-model="username" label="Ім'я" />
        <v-text-field v-model="password" label="Пароль" type="password" />
        <v-alert v-if="err" type="error" :text="err" class="mb-2" />
        <v-btn :loading="loading" color="primary" @click="signUp">Зареєструватися</v-btn>
      </div>
    </v-card>
  </div>
</template>
