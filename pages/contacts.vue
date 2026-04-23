<script setup lang="ts">
import { computed } from 'vue'

const client = useSupabaseClient()
const name = ref(''); const email = ref(''); const message = ref('')
const success = ref(''); const errorMsg = ref(''); const sending = ref(false)

const check_values = computed(() => name.value.trim() !== '' && email.value.trim() !== '' && message.value.trim() !== '')

watch([name, email, message], () => {
  if (check_values.value) { errorMsg.value = ''; success.value = '' }
})

const validEmail = (v: string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)

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
  <div class="container py-10 md:py-12 lg:py-14">
    <div class="max-w-6xl">
      <div class="divider"></div>
      <h1 class="mb-3">
        Контакти
      </h1>
      <p class="text-sm md:text-base text-[var(--color-text-muted)] max-w-2xl mb-8 md:mb-10">
        Завітайте до галереї або надішліть повідомлення. Ми будемо раді вашим враженням, запитанням і відгукам.
      </p>

      <div class="grid grid-cols-1 lg:grid-cols-[minmax(260px,0.85fr)_minmax(0,1.15fr)] gap-8 lg:gap-10 items-start">
        <!-- Info -->
        <div class="art-card">
          <div class="px-5 md:px-6 py-4 border-b border-[var(--color-line)] bg-[var(--color-surface-soft)]">
            <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)]">
              Інформація
            </div>
          </div>

          <div class="p-5 md:p-6 space-y-6">
            <div>
              <div class="field-label">Адреса</div>
              <div class="font-serif text-[1.15rem] md:text-[1.25rem] text-[var(--color-text)] leading-snug">
                вул. Прикладна, 1, Київ
              </div>
            </div>

            <div>
              <div class="field-label">Телефон</div>
              <div class="font-serif text-[1.15rem] md:text-[1.25rem] text-[var(--color-text)] leading-snug">
                +380 (00) 000-00-00
              </div>
            </div>

            <div>
              <div class="field-label">Email</div>
              <div
                class="font-serif text-[1.15rem] md:text-[1.25rem] text-[var(--color-text)] leading-snug break-words">
                info@example.com
              </div>
            </div>

            <div>
              <div class="field-label">Години роботи</div>
              <div class="font-serif text-[1.15rem] md:text-[1.25rem] text-[var(--color-text)] leading-snug">
                Вт–Нд 11:00–19:00
              </div>
              <div class="text-sm text-[var(--color-text-muted)] mt-1">
                Понеділок — вихідний
              </div>
            </div>
          </div>
        </div>

        <!-- Form -->
        <div class="art-card">
          <div class="px-5 md:px-6 py-4 border-b border-[var(--color-line)] bg-[var(--color-surface-soft)]">
            <div class="text-[11px] tracking-[0.16em] uppercase text-[var(--color-text-muted)]">
              Зворотний зв’язок
            </div>
          </div>

          <div class="p-5 md:p-6">
            <div class="text-sm text-[var(--color-text-soft)] mb-6 md:mb-7">
              Поділіться враженнями про виставку
            </div>

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
                <textarea v-model="message" rows="5" class="field-input resize-none"
                  placeholder="Ваше повідомлення..."></textarea>
              </div>

              <div v-if="errorMsg" class="alert-error">
                {{ errorMsg }}
              </div>

              <div v-if="success" class="alert-success">
                {{ success }}
              </div>

              <button v-if="check_values" :disabled="sending" @click="submitForm"
                class="btn-primary text-xs w-full justify-center mt-2">
                <span v-if="sending">Надсилання...</span>
                <span v-else>Надіслати повідомлення</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>