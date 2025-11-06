<script setup lang="ts">
definePageMeta({ layout: 'default' })
const goTickets = () => navigateTo('/tickets')
const goExhibitions = () => navigateTo('/exhibitions')
</script>

<template>
  <div class="container about page">
    <h1 class="title">Про нас</h1>

    <div class="intro section">
      <div class="text">
        <p>
          Art Gallery — це простір сучасного та класичного мистецтва, де тимчасові експозиції змінюють одна одну,
          а кожна виставка має власну історію. Ми працюємо з художниками, кураторами та спільнотою, щоби показувати
          найцікавіші події мистецького життя у доступному форматі.
        </p>
        <p class="muted">
          Наша місія — створювати місце зустрічі глядача й мистецтва: виставки, кураторські екскурсії, лекції,
          зустрічі з авторами та освітні програми.
        </p>
        <div class="cta">
          <v-btn color="primary" class="mr-2" @click="goExhibitions">Переглянути виставки</v-btn>
          <v-btn variant="tonal" @click="goTickets">Придбати квитки</v-btn>
        </div>
      </div>
      <div class="image img-frame">
        <v-img
          src="/img/about.png"
          alt="Виставковий простір"
          height="360"
          contain
        />
      </div>
    </div>

    <div class="grid section">
      <v-card class="pa-4">
        <h2 class="h">Години роботи</h2>
        <p>Вт–Нд: 11:00–19:00</p>
        <p>Пн: вихідний</p>
      </v-card>

      <v-card class="pa-4">
        <h2 class="h">Адреса</h2>
        <p>вул. Прикладна, 10, Львів</p>
        <p class="muted">Вхід з внутрішнього двору</p>
      </v-card>

      <v-card class="pa-4">
        <h2 class="h">Події</h2>
        <p>Екскурсії щосуботи, авторські зустрічі — щомісяця.</p>
      </v-card>
    </div>

    <div class="section">
      <v-alert type="info" variant="tonal">
        Для групових відвідувань або освіти напишіть у розділі <NuxtLink to="/contacts">Контакти</NuxtLink>.
      </v-alert>
    </div>
  </div>
</template>

<style scoped>
.page { padding-top: 18px; padding-bottom: 28px; }
.title { font-size: clamp(32px, 4vw, 48px); margin-bottom: 12px; }
.intro {
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 24px;
  align-items: center;
}
.cta { margin-top: 8px; }
.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
.h { font-size: 18px; margin-bottom: 6px; }
.image :deep(img) { object-fit: contain; }
@media (max-width: 1100px) {
  .intro { grid-template-columns: 1fr; }
  .grid { grid-template-columns: 1fr; }
}
</style>
