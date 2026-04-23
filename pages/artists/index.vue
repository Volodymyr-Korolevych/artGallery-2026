<script setup lang="ts">
definePageMeta({ layout: 'default' })
const client = useSupabaseClient()
const { data: items } = await useAsyncData('artists', async () => {
  const { data } = await client.from('artists').select('*').eq('isPublished', true).order('fullName')
  return data || []
})
</script>

<template>
  <div class="container py-10 md:py-12 lg:py-14">
    <div class="max-w-3xl mb-8 md:mb-10">
      <div class="divider"></div>
      <h1 class="mb-3">
        Художники
      </h1>
      <p class="text-sm md:text-base text-[var(--color-text-muted)] leading-relaxed">
        Автори, чиї роботи представлені у виставках галереї.
      </p>
    </div>

    <div v-if="items?.length" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 md:gap-7">
      <NuxtLink v-for="a in items" :key="a.id" :to="'/artists/' + a.slug"
        class="art-card group block overflow-hidden no-underline">
        <div class="img-frame aspect-[3/4] overflow-hidden">
          <img v-if="a.portraitUrl || a.imageUrl" :src="a.portraitUrl || a.imageUrl" :alt="a.fullName"
            class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-[1.03]" />
          <div v-else class="w-full h-full bg-[var(--color-surface-soft)] flex items-center justify-center">
            <span class="font-serif text-5xl text-[var(--color-text-muted)]/40">
              {{ a.fullName?.[0] }}
            </span>
          </div>
        </div>

        <div class="p-5 md:p-6">
          <h3 class="leading-snug mb-1 group-hover:text-[var(--color-accent)] transition-colors">
            {{ a.fullName }}
          </h3>

          <p v-if="a.country" class="text-[11px] tracking-[0.14em] uppercase text-[var(--color-text-muted)]">
            {{ a.country }}
          </p>

          <p v-if="a.bio || a.description"
            class="text-sm text-[var(--color-text-soft)] mt-3 line-clamp-3 leading-relaxed">
            {{ a.bio || a.description }}
          </p>
        </div>
      </NuxtLink>
    </div>

    <div v-else class="alert-info max-w-xl">
      Немає художників для показу.
    </div>
  </div>
</template>