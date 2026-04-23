<script setup lang="ts">
definePageMeta({ layout: 'default' })
</script>

<template>
  <div class="container py-10 md:py-12 lg:py-14">
    <!-- Hero -->
    <section
      class="grid grid-cols-1 lg:grid-cols-[minmax(0,0.95fr)_minmax(320px,1.05fr)] gap-10 lg:gap-12 items-center mb-12 md:mb-14">
      <div class="max-w-2xl">
        <div class="divider"></div>

        <h1 class="mb-4">
          Про нас
        </h1>

        <p class="text-[15px] md:text-base text-[var(--color-text-soft)] leading-relaxed mb-4">
          Art Gallery — це простір сучасного та класичного мистецтва, де тимчасові експозиції змінюють одна одну,
          а кожна виставка має власну історію. Ми працюємо з художниками, кураторами та спільнотою, щоби показувати
          найцікавіші події мистецького життя у доступному форматі.
        </p>

        <p class="text-sm md:text-[15px] text-[var(--color-text-muted)] leading-relaxed mb-7">
          Наша місія — створювати місце зустрічі глядача й мистецтва: виставки, кураторські екскурсії, лекції,
          зустрічі з авторами та освітні програми.
        </p>

        <div class="flex flex-wrap gap-3">
          <NuxtLink to="/exhibitions" class="btn-primary text-xs">
            Переглянути виставки
          </NuxtLink>
          <NuxtLink to="/tickets" class="btn-outline text-xs">
            Придбати квитки
          </NuxtLink>
        </div>
      </div>

      <div class="img-frame overflow-hidden bg-[var(--color-surface)]">
        <img src="/img/about.png" alt="Виставковий простір"
          class="w-full h-80 lg:h-[28rem] object-contain bg-[var(--color-surface-soft)]" />
      </div>
    </section>

    <!-- Info cards -->
    <section class="grid grid-cols-1 md:grid-cols-3 gap-5 md:gap-6 mb-10 md:mb-12">
      <div class="art-card p-6 md:p-7">
        <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-2">
          Години роботи
        </div>
        <div class="divider"></div>
        <p class="font-serif text-[1.2rem] md:text-[1.3rem] text-[var(--color-text)] mt-3">
          Вт–Нд: 11:00–19:00
        </p>
        <p class="text-sm text-[var(--color-text-muted)] mt-1">
          Понеділок — вихідний
        </p>
      </div>

      <div class="art-card p-6 md:p-7">
        <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-2">
          Адреса
        </div>
        <div class="divider"></div>
        <p class="font-serif text-[1.2rem] md:text-[1.3rem] text-[var(--color-text)] mt-3">
          вул. Прикладна, 10
        </p>
        <p class="text-sm text-[var(--color-text-muted)] mt-1">
          Львів · Вхід з внутрішнього двору
        </p>
      </div>

      <div class="art-card p-6 md:p-7">
        <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)] mb-2">
          Події
        </div>
        <div class="divider"></div>
        <p class="font-serif text-[1.2rem] md:text-[1.3rem] text-[var(--color-text)] mt-3">
          Щосуботи — екскурсії
        </p>
        <p class="text-sm text-[var(--color-text-muted)] mt-1">
          Авторські зустрічі — щомісяця
        </p>
      </div>
    </section>

    <!-- Note -->
    <section class="max-w-3xl">
      <div class="alert-info">
        Для групових відвідувань або освітніх програм зверніться у розділі
        <NuxtLink to="/contacts" class="underline underline-offset-2 font-medium ml-1">
          Контакти
        </NuxtLink>.
      </div>
    </section>
  </div>
</template>