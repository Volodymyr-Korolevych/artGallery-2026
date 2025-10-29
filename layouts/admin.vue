<script setup lang="ts">
const drawer = ref(true)
const nav = [
  { label: 'Експозиції', to: '/admin/exhibitions', icon: 'mdi-image-multiple' },
  { label: 'Художники',  to: '/admin/artists',     icon: 'mdi-account' },
  { label: 'Квитки',     to: '/admin/tickets',     icon: 'mdi-ticket-confirmation' },
  { label: 'Відгуки',    to: '/admin/reviews',     icon: 'mdi-message-text' },
]
</script>

<template>
  <div class="admin-wrap">
    <v-navigation-drawer
      v-model="drawer"
      permanent
      color="surface"
      class="admin-drawer"
    >
      <div class="px-4 py-4 text-subtitle-1 font-weight-medium">Адмін-панель</div>
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
    </v-navigation-drawer>

    <div class="admin-content">
      <slot />
    </div>
  </div>
</template>

<style>
.admin-wrap {
  display: grid;
  grid-template-columns: 280px 1fr;
  min-height: calc(100vh - 72px); /* 72px — відступ під AppHeader у main layout */
}
.admin-drawer {
  border-right: 1px solid rgba(0,0,0,0.08);
}
.admin-content {
  padding: 24px;
  overflow: auto;
}
@media (max-width: 960px) {
  .admin-wrap { grid-template-columns: 220px 1fr; }
}
</style>
