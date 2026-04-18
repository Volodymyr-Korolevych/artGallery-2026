<script setup lang="ts">
useHead({
  htmlAttrs: { lang: 'uk' }
})
</script>

<template>
  <div class="min-h-screen bg-stone-50 flex flex-col">
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>
