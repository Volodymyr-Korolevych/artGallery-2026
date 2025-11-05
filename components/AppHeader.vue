<script setup lang="ts">
const route = useRoute()
const go = (p: string) => navigateTo(p)

const links = [
  { to: '/', label: 'Головна' },
  { to: '/exhibitions/current', label: 'Експозиції' },  // всередині будуть підсторінки current/past/upcoming
  { to: '/artists', label: 'Художники' },
  { to: '/tickets', label: 'Квитки' },
  { to: '/reviews', label: 'Відгуки' },
  { to: '/contacts', label: 'Контакти' },
]
</script>

<template>
  <!-- app -> резервує простір у v-main; fixed top -->
  <v-app-bar app flat elevation="1" color="white">
    <div class="container head">
      <div class="brand" @click="go('/')">Art Gallery</div>
      <nav class="nav">
        <NuxtLink
          v-for="l in links"
          :key="l.to"
          :to="l.to"
          class="nav-link"
          :class="{ active: route.path === l.to || route.path.startsWith(l.to + '/') }"
        >{{ l.label }}</NuxtLink>
      </nav>
    </div>
  </v-app-bar>
</template>

<style scoped>
.head{
  display:flex;
  align-items:center;
  justify-content:space-between;
  min-height:64px;
}
.brand{
  font-weight:700;
  letter-spacing:.2px;
  cursor:pointer;
}
.nav{
  display:flex; gap: 18px; align-items:center;
}
.nav-link{
  text-decoration:none;
  color: inherit;
  opacity:.8;
  padding: 6px 8px;
  border-radius: 8px;
}
.nav-link:hover{ opacity:1; background: rgba(0,0,0,.04); }
.nav-link.active{ color: var(--brand); opacity:1; background: rgba(30,64,175,.08); }
</style>
