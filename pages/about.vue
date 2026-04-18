<script setup lang="ts">
definePageMeta({ layout: 'default' })
</script>

<template>
  <div>
    <!-- Hero -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-20 items-center mb-16">
      <div>
        <div class="divider"></div>
        <h1 class="font-serif text-5xl lg:text-6xl font-semibold leading-tight text-neutral-900 mb-6">
          Про нас
        </h1>
        <p class="text-base text-neutral-600 leading-relaxed mb-4">
          Art Gallery — це простір сучасного та класичного мистецтва, де тимчасові експозиції змінюють одна одну,
          а кожна виставка має власну історію. Ми працюємо з художниками, кураторами та спільнотою, щоби показувати
          найцікавіші події мистецького життя у доступному форматі.
        </p>
        <p class="text-sm text-neutral-500 leading-relaxed mb-8">
          Наша місія — створювати місце зустрічі глядача й мистецтва: виставки, кураторські екскурсії, лекції,
          зустрічі з авторами та освітні програми.
        </p>
        <div class="flex flex-wrap gap-3">
          <NuxtLink to="/exhibitions" class="btn-primary text-xs">Переглянути виставки</NuxtLink>
          <NuxtLink to="/tickets" class="btn-outline text-xs">Придбати квитки</NuxtLink>
        </div>
      </div>

      <div class="img-frame overflow-hidden">
        <img src="/img/about.png" alt="Виставковий простір" class="w-full h-80 lg:h-96 object-contain bg-neutral-50" />
      </div>
    </div>

    <!-- Info cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
      <div class="border border-neutral-100 bg-white p-7">
        <div class="text-xs tracking-widest uppercase text-neutral-400 mb-3">Години роботи</div>
        <div class="divider"></div>
        <p class="font-serif text-lg text-neutral-900 mt-3">Вт–Нд: 11:00–19:00</p>
        <p class="text-sm text-neutral-500 mt-1">Понеділок — вихідний</p>
      </div>

      <div class="border border-neutral-100 bg-white p-7">
        <div class="text-xs tracking-widest uppercase text-neutral-400 mb-3">Адреса</div>
        <div class="divider"></div>
        <p class="font-serif text-lg text-neutral-900 mt-3">вул. Прикладна, 10</p>
        <p class="text-sm text-neutral-500 mt-1">Львів · Вхід з внутрішнього двору</p>
      </div>

      <div class="border border-neutral-100 bg-white p-7">
        <div class="text-xs tracking-widest uppercase text-neutral-400 mb-3">Події</div>
        <div class="divider"></div>
        <p class="font-serif text-lg text-neutral-900 mt-3">Щосуботи — екскурсії</p>
        <p class="text-sm text-neutral-500 mt-1">Авторські зустрічі — щомісяця</p>
      </div>
    </div>

    <!-- Note -->
    <div class="alert-info">
      Для групових відвідувань або освітніх програм зверніться у розділі
      <NuxtLink to="/contacts" class="underline underline-offset-2 font-medium ml-1">Контакти</NuxtLink>.
    </div>
  </div>
</template>
