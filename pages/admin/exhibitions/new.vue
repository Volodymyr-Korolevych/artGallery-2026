<template>
  <div class="p-6 space-y-6">
    <div class="grid gap-4 md:grid-cols-2">
      <div>
        <label class="block mb-2 text-sm font-medium">Назва виставки</label>
        <input v-model="title" type="text" class="w-full border rounded px-3 py-2" placeholder="Наприклад: «Тіні та Світло»" />
      </div>
      <div>
        <label class="block mb-2 text-sm font-medium">Slug</label>
        <input v-model="slug" type="text" class="w-full border rounded px-3 py-2" placeholder="naprklad-tini-ta-svitlo" />
      </div>
    </div>

    <div>
      <label class="block mb-2 text-sm font-medium">Опис</label>
      <textarea v-model="description" rows="5" class="w-full border rounded px-3 py-2" placeholder="Короткий опис виставки..."></textarea>
    </div>

    <div class="grid gap-4 md:grid-cols-2">
      <div>
        <label class="block mb-2 text-sm font-medium">Художник (ID)</label>
        <input v-model.number="painterId" type="number" min="1" class="w-full border rounded px-3 py-2" placeholder="ID художника" />
      </div>
      <div>
        <label class="block mb-2 text-sm font-medium">Обкладинка (URL)</label>
        <input v-model="coverUrl" type="url" class="w-full border rounded px-3 py-2" placeholder="https://..." />
      </div>
    </div>

    <div>
      <label class="block mb-2 text-sm font-medium">Зображення картки (URL)</label>
      <input v-model="cardUrl" type="url" class="w-full border rounded px-3 py-2" placeholder="https://..." />
    </div>

    <ClientOnly>
      <div>
        <label class="block mb-2 text-sm font-medium">Період виставки</label>
        <VueDatePicker
          v-model="period"
          :locale="uk"
          range
          :week-start="1"
          :enable-time-picker="false"
          auto-apply
          format="dd.MM.yyyy"
          placeholder="Оберіть період (з — по)"
        />
      </div>
    </ClientOnly>

    <div class="pt-4">
      <button
        :disabled="!isValid"
        class="px-4 py-2 rounded bg-blue-600 text-white disabled:opacity-50"
        @click="submit"
      >
        Зберегти виставку
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import VueDatePicker from '@vuepic/vue-datepicker'
import { uk } from 'date-fns/locale'
import { format } from 'date-fns'

const title = ref('')
const slug = ref('')
const description = ref('')
const painterId = ref<number | null>(null)
const coverUrl = ref('')
const cardUrl = ref('')

// Діапазон дат
const period = ref<[Date | null, Date | null]>([null, null])

const toYMD = (d: Date | null) => (d ? format(d, 'yyyy-MM-dd') : null)
const startDate = computed(() => toYMD(period.value?.[0] ?? null))
const endDate   = computed(() => toYMD(period.value?.[1] ?? null))

const isValid = computed(() =>
  !!title.value.trim() &&
  !!startDate.value &&
  !!endDate.value &&
  !!painterId.value
)

const submit = async () => {
  if (!isValid.value) return
  const payload = {
    title: title.value,
    slug: slug.value,
    description: description.value,
    startDate: startDate.value,
    endDate: endDate.value,
    painterId: painterId.value,
    coverUrl: coverUrl.value,
    cardUrl: cardUrl.value,
    isPublished: true
  }
  // TODO: замінити на реальний запит до API
  console.log('Submit payload', payload)
}
</script>
