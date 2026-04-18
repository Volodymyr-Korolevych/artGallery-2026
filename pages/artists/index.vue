<script setup lang="ts">
definePageMeta({ layout: 'default' })
const client = useSupabaseClient()
const { data: items } = await useAsyncData('artists', async () => {
  const { data } = await client.from('artists').select('*').eq('isPublished', true).order('fullName')
  return data || []
})
</script>

<template>
  <div>
    <div class="divider"></div>
    <h1 class="font-serif text-5xl font-semibold text-neutral-900 mb-10">Художники</h1>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <NuxtLink
        v-for="a in items"
        :key="a.id"
        :to="'/artists/' + a.slug"
        class="art-card group block p-0 no-underline overflow-hidden"
      >
        <!-- Portrait image -->
        <div class="img-frame aspect-[3/4] overflow-hidden">
          <img
            v-if="a.portraitUrl || a.imageUrl"
            :src="a.portraitUrl || a.imageUrl"
            :alt="a.fullName"
            class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-[1.03]"
          />
          <div v-else class="w-full h-full bg-neutral-100 flex items-center justify-center">
            <span class="font-serif text-4xl text-neutral-300">{{ a.fullName?.[0] }}</span>
          </div>
        </div>
        <div class="p-5">
          <h3 class="font-serif text-xl font-semibold text-neutral-900 mb-1 group-hover:text-neutral-600 transition-colors">
            {{ a.fullName }}
          </h3>
          <p v-if="a.country" class="text-xs text-neutral-400 tracking-wider uppercase">{{ a.country }}</p>
          <p v-if="a.bio || a.description" class="text-sm text-neutral-600 mt-2 line-clamp-2 leading-relaxed">
            {{ a.bio || a.description }}
          </p>
        </div>
      </NuxtLink>
    </div>

    <div v-if="!items?.length" class="text-sm text-neutral-400 italic mt-8">Немає художників для показу.</div>
  </div>
</template>
