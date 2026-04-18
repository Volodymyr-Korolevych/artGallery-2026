<script setup lang="ts">
const nav = [
  { label: 'Експозиції', to: '/admin/exhibitions', icon: '🖼' },
  { label: 'Художники', to: '/admin/artists', icon: '👤' },
  { label: 'Квитки', to: '/admin/tickets', icon: '🎟' },
  { label: 'Відгуки', to: '/admin/reviews', icon: '💬' },
]
</script>

<template>
  <div class="min-h-screen flex flex-col">
    <AppHeader />
    <div class="flex flex-1">
      <!-- Sidebar -->
      <aside class="w-64 shrink-0 bg-white border-r border-neutral-100 py-6 px-4">
        <div class="text-xs tracking-widest uppercase text-neutral-400 font-medium px-3 mb-4">
          Адмін-панель
        </div>
        <nav class="space-y-0.5">
          <NuxtLink v-for="item in nav" :key="item.to" :to="item.to"
            class="flex items-center gap-3 px-3 py-2.5 text-sm text-neutral-600 hover:text-neutral-900 hover:bg-neutral-50 transition-colors rounded-sm group"
            active-class="!text-neutral-900 !bg-neutral-100 font-medium">
            <span class="text-base">{{ item.icon }}</span>
            {{ item.label }}
          </NuxtLink>
        </nav>
      </aside>

      <!-- Content -->
      <main class="flex-1 overflow-auto p-8 min-w-0">
        <slot />
      </main>
    </div>
  </div>
</template>
