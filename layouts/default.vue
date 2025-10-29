<template>
  <div class="layout-wrap">
    <AppHeader />
    <main class="app-main">
      <slot />
    </main>
    <AppFooter />
  </div>
</template>

<style>
.layout-wrap { display: flex; flex-direction: column; min-height: 100vh; }
.app-main { padding-top: 72px; flex: 1 0 auto; }
@media (max-width: 600px) { .app-main { padding-top: 80px; } }
</style>
