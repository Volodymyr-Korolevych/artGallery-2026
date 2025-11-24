<script setup lang="ts">
</script>

<template>
  <!-- УВАГА: v-app та v-main уже у app.vue (зафіксовано раніше).
       Тут — тільки контент лейауту під AppHeader. -->
  <AppHeader />
  <div class="container page-wrap">
    <slot />
  </div>
  <AppFooter v-if="false" /> <!-- додасте пізніше; залишено місце -->
</template>

<style>
body {
  caret-color: transparent;
}
input, textarea {
  caret-color: auto;
}
.page-wrap{
  padding-top: 18px;   /* невеликий відступ від хедера */
  padding-bottom: 28px;
}
</style>
