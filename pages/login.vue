<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const email = ref('')
const password = ref('')
const username = ref('')

const err = ref('')
const loading = ref(false)
const tab = ref<'signin'|'signup'>('signin')

watchEffect(() => {
  if (user.value) {
    navigateTo('/')
  }
})

const signIn = async () => {
  err.value = ''; loading.value = true
  const { error } = await supabase.auth.signInWithPassword({ email: email.value, password: password.value })
  loading.value = false
  if (error) { err.value = error.message; return }
  // admin redirect handled by redirect-admin.global middleware when navigating from /login to /
  navigateTo('/')
}

const signUp = async () => {
  err.value=''; loading.value = true
  const uname = username.value.trim() || email.value.split('@')[0]
  const { data, error } = await supabase.auth.signUp({
    email: email.value,
    password: password.value,
    // options: { data: { username: uname } }
  })
  loading.value = false
  console.log("signUp data:",  data)
  if (error) { err.value = error.message; return }
  else if (data.user) {
    await supabase.from('profiles').insert({
      id: data.user.id,
      username: uname, // поле з форми
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

      <div v-if="tab==='signin'">
        <v-text-field v-model="email" label="Email" type="email" />
        <v-text-field v-model="password" label="Пароль" type="password" />
        <v-alert v-if="err" type="error" :text="err" class="mb-2" />
        <v-btn :loading="loading" color="primary" @click="signIn">Увійти</v-btn>
      </div>

      <div v-else>
        <v-text-field v-model="email" label="Email" type="email" />
        <v-text-field v-model="username" label="Username (можна залишити порожнім)" />
        <v-text-field v-model="password" label="Пароль" type="password" />
        <v-alert v-if="err" type="error" :text="err" class="mb-2" />
        <v-btn :loading="loading" color="primary" @click="signUp">Зареєструватися</v-btn>
      </div>
    </v-card>
  </div>
</template>
