<script setup lang="ts">
const props = defineProps<{
  slug: string
  title: string
  short: string|null
  coverUrl: string|null
  artist?: { fullName: string; slug: string } | null
}>()
const go = (p:string) => navigateTo(p)
const goArtist = () => { if (props.artist?.slug) go('/artists/'+props.artist.slug) }
const goDetails = () => go('/exhibitions/'+props.slug)
</script>

<template>
  <v-card class="row">
    <div class="left img-frame">
      <v-img v-if="coverUrl" :src="coverUrl" :alt="title" height="140" width="220" cover />
      <div v-else class="ph">—</div>
    </div>
    <div class="right serif">
      <h3 class="title">{{ title }}</h3>
      <div class="artist" v-if="artist">
        Художник: <a class="a" @click.prevent="goArtist">{{ artist.fullName }}</a>
      </div>
      <div class="short" v-if="short">{{ short }}</div>
      <div class="actions">
        <v-btn color="primary" @click="goDetails">Детальніше</v-btn>
      </div>
    </div>
  </v-card>
</template>

<style scoped>
.row{
  display:grid;
  grid-template-columns: 240px 1fr;
  gap: 16px;
  padding: 12px;
}
.left{ width: 240px; }
.ph{ height:140px; display:flex; align-items:center; justify-content:center; color:rgba(0,0,0,.45) }
.right{ display:grid; gap:6px; }
.serif { font-family: "Cormorant Garamond", serif; }
.title{ font-size: 22px; line-height:1.2; }
.a{ color:inherit; text-decoration:underline; cursor:pointer; }
.short{ font-size: 16px; line-height: 1.45; }
</style>
