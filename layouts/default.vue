<template>
  <v-app>
    <AppHeader />
    <v-main class="app-main">
      <slot />
    </v-main>
  </v-app>
</template>

<style>
/* базова висота апбара у Vuetify = 64px (comfortable), додамо запас */
.app-main { padding-top: 72px; }
@media (max-width: 600px) { .app-main { padding-top: 80px; } }
</style>
