<script setup lang="ts">
// Головний корінь застосунку, як ти й сказала
useHead({
  htmlAttrs: { lang: 'uk' }
})
</script>

<template>
  <v-app>
    <v-main>
      <NuxtLayout>
        <NuxtPage />
      </NuxtLayout>
    </v-main>
  </v-app>
</template>
