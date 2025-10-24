<script setup lang="ts">
const user = useSupabaseUser()
const client = useSupabaseClient()
const router = useRouter()
const onLogout = async () => {
  await client.auth.signOut()
  router.push('/login')
}
</script>

<template>
  <div>
    <v-btn v-if="!user" to="/login" variant="flat" color="primary">Увійти</v-btn>
    <v-menu v-else>
      <template #activator="{ props }">
        <v-btn v-bind="props" color="primary" variant="flat">{{ user?.email }}</v-btn>
      </template>
      <v-list>
        <v-list-item to="/profile">Профіль</v-list-item>
        <v-list-item to="/admin">Адмінка</v-list-item>
        <v-list-item @click="onLogout">Вийти</v-list-item>
      </v-list>
    </v-menu>
  </div>
</template>
