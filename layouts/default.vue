<template>
  <div class="min-h-screen flex flex-col">
    <AppHeader />
    <main class="flex-1">
      <div class="container py-10 lg:py-14">
        <slot />
      </div>
    </main>
    <AppFooter />
  </div>
</template>
