<template>
  <v-app-bar density="comfortable" flat>
    <v-app-bar-title>Галерея</v-app-bar-title>
    <v-spacer></v-spacer>
    <v-btn to="/" variant="text">Про нас</v-btn>
    <v-btn to="/exhibitions/current" variant="text">Виставки</v-btn>
    <v-btn to="/tickets" variant="text">Придбати квитки</v-btn>
    <v-btn to="/contacts" variant="text">Контакти</v-btn>
    <v-divider vertical class="mx-2" />
    <AuthButton />
  </v-app-bar>
</template>
