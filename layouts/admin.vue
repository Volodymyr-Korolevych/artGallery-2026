<script setup lang="ts">
const nav = [
  { label: 'Експозиції', to: '/admin/exhibitions', icon: '🖼' },
  { label: 'Художники', to: '/admin/artists', icon: '👤' },
  { label: 'Квитки', to: '/admin/tickets', icon: '🎟' },
  { label: 'Відгуки', to: '/admin/reviews', icon: '💬' },
]
</script>

<template>
  <div class="min-h-screen flex flex-col bg-[var(--color-bg)] text-[var(--color-text)]">
    <AppHeader />

    <div class="flex flex-1 min-h-0">
      <!-- Sidebar -->
      <aside class="w-72 shrink-0 border-r border-[var(--color-line)] bg-[var(--color-surface)]">
        <div class="px-5 py-6 border-b border-[var(--color-line)]">
          <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-2">
            Адміністрування
          </div>
          <div class="font-serif text-[1.35rem] text-[var(--color-text)] leading-none">
            Art Gallery
          </div>
        </div>

        <nav class="p-4 space-y-1.5">
          <NuxtLink v-for="item in nav" :key="item.to" :to="item.to"
            class="flex items-center gap-3 px-4 py-3 text-sm text-[var(--color-text-soft)] hover:text-[var(--color-text)] hover:bg-[var(--color-accent-soft)] transition-colors rounded-sm group"
            active-class="!text-[var(--color-text)] !bg-[var(--color-accent-soft)] font-medium">
            <span class="text-base opacity-80 group-hover:opacity-100">{{ item.icon }}</span>
            <span class="tracking-[0.01em]">{{ item.label }}</span>
          </NuxtLink>
        </nav>
      </aside>

      <!-- Content -->
      <main class="flex-1 overflow-auto min-w-0">
        <div class="px-6 py-8 md:px-8 md:py-10 lg:px-10 lg:py-12">
          <slot />
        </div>
      </main>
    </div>
  </div>
</template>