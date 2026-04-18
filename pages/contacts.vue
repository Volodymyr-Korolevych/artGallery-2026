<script setup lang="ts">
import { computed } from 'vue'

const client = useSupabaseClient()
const name = ref(''); const email = ref(''); const message = ref('')
const success = ref(''); const errorMsg = ref(''); const sending = ref(false)

const check_values = computed(() => name.value.trim() !== '' && email.value.trim() !== '' && message.value.trim() !== '')

watch([name, email, message], () => {
  if (check_values.value) { errorMsg.value = ''; success.value = '' }
})

const validEmail = (v:string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)

const submitForm = async () => {
  success.value = ''; errorMsg.value = ''
  if (!name.value.trim() || !validEmail(email.value) || !message.value.trim()) {
    errorMsg.value = 'Будь ласка, заповніть всі поля коректно.'; return
  }
  sending.value = true
  const { error } = await client.from('contact_messages').insert({
    name: name.value.trim(), email: email.value.trim(), message: message.value.trim()
  })
  sending.value = false
  if (error) { errorMsg.value = error.message }
  else {
    success.value = 'Дякуємо! Ваше повідомлення надіслано.'
    name.value = ''; email.value = ''; message.value = ''
  }
}
</script>

<template>
  <div class="max-w-3xl">
    <div class="divider"></div>
    <h1 class="font-serif text-5xl font-semibold text-neutral-900 mb-10">Контакти</h1>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-10 mb-14">
      <!-- Info -->
      <div class="space-y-6">
        <div>
          <div class="text-xs tracking-widest uppercase text-neutral-400 mb-1">Адреса</div>
          <div class="font-serif text-lg text-neutral-900">вул. Прикладна, 1, Київ</div>
        </div>
        <div>
          <div class="text-xs tracking-widest uppercase text-neutral-400 mb-1">Телефон</div>
          <div class="font-serif text-lg text-neutral-900">+380 (00) 000-00-00</div>
        </div>
        <div>
          <div class="text-xs tracking-widest uppercase text-neutral-400 mb-1">Email</div>
          <div class="font-serif text-lg text-neutral-900">info@example.com</div>
        </div>
        <div>
          <div class="text-xs tracking-widest uppercase text-neutral-400 mb-1">Години роботи</div>
          <div class="font-serif text-lg text-neutral-900">Вт–Нд 11:00–19:00</div>
          <div class="text-sm text-neutral-500">Понеділок — вихідний</div>
        </div>
      </div>

      <!-- Form -->
      <div>
        <div class="text-sm font-medium text-neutral-700 mb-6">Поділіться враженнями про виставку</div>

        <div class="space-y-5">
          <div>
            <label class="field-label">Ваше ім'я</label>
            <input v-model="name" type="text" class="field-input" placeholder="Введіть ім'я" />
          </div>
          <div>
            <label class="field-label">Email</label>
            <input v-model="email" type="email" class="field-input" placeholder="your@email.com" />
          </div>
          <div>
            <label class="field-label">Повідомлення</label>
            <textarea v-model="message" rows="4" class="field-input resize-none" placeholder="Ваше повідомлення..."></textarea>
          </div>

          <div v-if="errorMsg" class="alert-error">{{ errorMsg }}</div>
          <div v-if="success" class="alert-success">{{ success }}</div>

          <button
            v-if="check_values"
            :disabled="sending"
            @click="submitForm"
            class="btn-primary text-xs w-full justify-center"
          >
            <span v-if="sending">Надсилання...</span>
            <span v-else>Надіслати повідомлення</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
