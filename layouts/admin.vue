<script setup lang="ts">
const nav = [
  { label: 'Експозиції', to: '/admin/exhibitions', icon: 'mdi-image-multiple' },
  { label: 'Художники',  to: '/admin/artists',     icon: 'mdi-account' },
  { label: 'Квитки',     to: '/admin/tickets',     icon: 'mdi-ticket-confirmation' },
  { label: 'Відгуки',    to: '/admin/reviews',     icon: 'mdi-message-text' },
]
</script>

<template>
  <div class="admin-shell">
    <AppHeader />

    <div class="admin-wrap">
      <aside class="admin-aside">
        <div class="aside-title">Адмін-панель</div>
        <v-divider />
        <v-list nav density="comfortable">
          <v-list-item
            v-for="item in nav"
            :key="item.to"
            :to="item.to"
            :prepend-icon="item.icon"
            :title="item.label"
            rounded
          />
        </v-list>
      </aside>

      <main class="admin-content">
        <slot />
      </main>
    </div>
  </div>
</template>

<style>
.admin-shell {
  min-height: 100vh;
  width: 100%;
}
/* двоколонний grid без обмежень ширини */
.admin-wrap {
  display: grid;
  grid-template-columns: 280px minmax(0, 1fr);
  gap: 0;
  width: 100%;
  max-width: none;
  min-width: 0;
}
.admin-aside {
  border-right: 1px solid rgba(0,0,0,0.08);
  padding: 16px 8px;
}
.aside-title {
  padding: 8px 12px;
  font-weight: 600;
  font-size: 14px;
  opacity: .8;
  margin-bottom: 8px;
}
.admin-content {
  padding: 24px;
  width: 100%;
  max-width: none;
  min-width: 0;   /* критично, щоб контент не стискався */
  overflow: auto;
}
@media (max-width: 960px) {
  .admin-wrap { grid-template-columns: 220px minmax(0, 1fr); }
}
</style>
