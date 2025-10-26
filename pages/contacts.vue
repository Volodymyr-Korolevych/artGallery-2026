<script setup lang="ts">
const client = useSupabaseClient()

const name = ref('')
const email = ref('')
const message = ref('')
const success = ref('')
const errorMsg = ref('')
const sending = ref(false)

const validEmail = (v:string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)

const submitForm = async () => {
  success.value = ''
  errorMsg.value = ''

  if (!name.value.trim() || !validEmail(email.value) || !message.value.trim()) {
    errorMsg.value = 'Будь ласка, заповніть всі поля коректно.'
    return
  }
  sending.value = true
  const { error } = await client.from('contact_messages').insert({
    name: name.value.trim(),
    email: email.value.trim(),
    message: message.value.trim()
  })
  sending.value = false
  if (error) {
    errorMsg.value = error.message
  } else {
    success.value = 'Дякуємо! Ваше повідомлення надіслано.'
    name.value = ''
    email.value = ''
    message.value = ''
  }
}
</script>

<template>
  <div class="max-w-800 mx-auto">
    <h1 class="text-h4 mb-6">Контакти</h1>

    <v-card class="mb-6 pa-4">
      <div class="text-body-1">
        <strong>Адреса:</strong> вул. Прикладна, 1, Київ<br>
        <strong>Телефон:</strong> +380 (00) 000-00-00<br>
        <strong>Email:</strong> info@example.com<br>
        <strong>Години роботи:</strong> Вт–Нд 11:00–19:00 (Пн — вихідний)
      </div>
    </v-card>

    <v-card class="pa-4">
      <div class="text-h6 mb-4">Напишіть нам</div>
      <v-text-field v-model="name" label="Ваше ім’я" />
      <v-text-field v-model="email" label="Email" type="email" />
      <v-textarea v-model="message" label="Повідомлення" rows="5" />
      <v-alert v-if="errorMsg" type="error" :text="errorMsg" class="mb-2" />
      <v-alert v-if="success" type="success" :text="success" class="mb-2" />
      <v-btn :loading="sending" color="primary" @click="submitForm">Надіслати</v-btn>
    </v-card>
  </div>
</template>
