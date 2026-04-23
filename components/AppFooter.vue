<template>
  <footer class="mt-auto border-t border-[var(--color-line)] bg-[var(--color-bg)] text-[var(--color-text-soft)]">
    <div class="container py-10 md:py-12">
      <div class="flex flex-col md:flex-row items-center justify-between gap-6">
        <div class="text-center md:text-left">
          <div class="font-serif text-[var(--color-text)] text-lg font-semibold tracking-[0.08em] mb-1">
            Art Gallery
          </div>
          <div class="text-xs tracking-[0.04em]">вул. Прикладна, 10, Львів</div>
        </div>

        <nav class="flex flex-wrap justify-center gap-6 text-[11px] md:text-xs tracking-[0.16em] uppercase">
          <NuxtLink to="/about" class="hover:text-[var(--color-text)] transition-colors">Про нас</NuxtLink>
          <NuxtLink to="/exhibitions" class="hover:text-[var(--color-text)] transition-colors">Виставки</NuxtLink>
          <NuxtLink to="/tickets" class="hover:text-[var(--color-text)] transition-colors">Квитки</NuxtLink>
          <NuxtLink to="/contacts" class="hover:text-[var(--color-text)] transition-colors">Контакти</NuxtLink>
        </nav>

        <div class="text-xs text-[var(--color-text-muted)]">
          &copy; {{ new Date().getFullYear() }} Art Gallery
        </div>
      </div>
    </div>
  </footer>
</template>