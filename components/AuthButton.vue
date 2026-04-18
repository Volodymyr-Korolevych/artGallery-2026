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
    <NuxtLink v-if="!user" to="/login" class="btn-primary text-xs">Увійти</NuxtLink>
    <div v-else class="flex items-center gap-3">
      <span class="text-sm text-neutral-600">{{ user?.email }}</span>
      <button @click="onLogout" class="btn-outline text-xs px-4 py-1.5">Вийти</button>
    </div>
  </div>
</template>
