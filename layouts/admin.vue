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
      <aside class="w-60 shrink-0 border-r border-[var(--color-line)] bg-[var(--color-surface)]">
        <div class="px-4 py-5 border-b border-[var(--color-line)]">
          <div class="text-[10px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-1.5">
            Адміністрування
          </div>
          <div class="font-serif text-[1.18rem] text-[var(--color-text-soft)] leading-none">
            Art Gallery
          </div>
        </div>

        <nav class="p-3 space-y-1">
          <NuxtLink v-for="item in nav" :key="item.to" :to="item.to" class="admin-sidebar-link group"
            active-class="active">
            <span class="text-sm opacity-65 group-hover:opacity-90">{{ item.icon }}</span>
            <span class="tracking-[0.01em]">{{ item.label }}</span>
          </NuxtLink>
        </nav>
      </aside>

      <!-- Content -->
      <main class="flex-1 overflow-auto min-w-0">
        <div class="px-5 py-7 md:px-7 md:py-8 lg:px-8 lg:py-9">
          <slot />
        </div>
      </main>
    </div>
  </div>
</template>