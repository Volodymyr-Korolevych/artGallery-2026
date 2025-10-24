<script setup lang="ts">
const client = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()
const route = useRoute()
const email = ref('')
const password = ref('')
const loading = ref(false)
const err = ref('')

watch(user, () => {
  if (user.value) {
    router.push((route.query.next as string) || '/')
  }
})

const onLogin = async () => {
  loading.value = true
  err.value = ''
  const { error } = await client.auth.signInWithPassword({ email: email.value, password: password.value })
  loading.value = false
  if (error) err.value = error.message
}
</script>

<template>
  <v-container class="max-w-480">
    <h1 class="text-h5 mb-4">Вхід</h1>
    <v-text-field v-model="email" label="Email" type="email" />
    <v-text-field v-model="password" label="Пароль" type="password" />
    <v-alert v-if="err" type="error" :text="err" class="mb-2" />
    <v-btn :loading="loading" @click="onLogin" color="primary">Увійти</v-btn>
  </v-container>
</template>
