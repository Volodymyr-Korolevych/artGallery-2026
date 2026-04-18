<template>
  <footer class="bg-neutral-900 text-neutral-400 mt-auto">
    <div class="container py-10">
      <div class="flex flex-col md:flex-row items-center justify-between gap-6">
        <div>
          <div class="font-serif text-white text-lg font-semibold tracking-wider mb-1">Art Gallery</div>
          <div class="text-xs">вул. Прикладна, 10, Львів</div>
        </div>

        <nav class="flex flex-wrap justify-center gap-6 text-xs tracking-wider">
          <NuxtLink to="/about" class="hover:text-white transition-colors">Про нас</NuxtLink>
          <NuxtLink to="/exhibitions" class="hover:text-white transition-colors">Виставки</NuxtLink>
          <NuxtLink to="/tickets" class="hover:text-white transition-colors">Квитки</NuxtLink>
          <NuxtLink to="/contacts" class="hover:text-white transition-colors">Контакти</NuxtLink>
        </nav>

        <div class="text-xs">
          &copy; {{ new Date().getFullYear() }} Art Gallery
        </div>
      </div>
    </div>
  </footer>
</template>

