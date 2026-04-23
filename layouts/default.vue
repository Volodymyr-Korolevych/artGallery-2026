<template>
  <div class="min-h-screen flex flex-col bg-[var(--color-bg)] text-[var(--color-text)]">
    <AppHeader />

    <main class="flex-1">
      <slot />
    </main>

    <AppFooter />
  </div>
</template>