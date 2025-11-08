<script setup lang="ts">
const props = defineProps<{
  slug: string
  title: string
  status: 'past'|'current'|'upcoming'|null
  startDate: string|null
  endDate: string|null
  cardUrl: string|null
  artist?: { fullName: string, slug: string } | null
}>()
const go = (p:string) => navigateTo(p)

const statusLabel = (s: any) => s==='past' ? 'Минула' : s==='current' ? 'Поточна' : s==='upcoming' ? 'Майбутня' : ''
const fmtRange = (s: string|null, e: string|null) => {
  const toD = (v:string|null)=> v? new Date(v):null
  const f = (d:Date)=> d.toLocaleDateString('uk-UA',{year:'numeric',month:'long',day:'numeric'})
  const sd = toD(s), ed = toD(e)
  if(sd && ed) return `${f(sd)} — ${f(ed)}`
  if(sd) return f(sd)
  if(ed) return f(ed)
  return ''
}
const goArtist = () => { if (props.artist?.slug) go('/artists/'+props.artist.slug) }
const goDetails = () => go('/exhibitions/'+props.slug)
</script>

<template>
  <v-card class="xcard">
    <div class="img-frame">
      <v-img v-if="cardUrl" :src="cardUrl" :alt="title" height="260" contain />
      <div v-else class="ph">Зображення відсутнє</div>
    </div>

    <div class="body serif">
      <div class="status" v-if="status">{{ statusLabel(status) }}</div>
      <h3 class="title">{{ title }}</h3>
      <div class="dates" v-if="startDate || endDate">{{ fmtRange(startDate, endDate) }}</div>

      <div class="artist" v-if="artist">
        Художник: <a class="a" @click.prevent="goArtist">{{ artist.fullName }}</a>
      </div>

      <div class="actions">
        <v-btn color="primary" @click="goDetails">Детальніше</v-btn>
      </div>
    </div>
  </v-card>
</template>

<style scoped>
.xcard{ display:grid; gap:10px; padding:12px; }
.ph{ height:260px; display:flex; align-items:center; justify-content:center; color:rgba(0,0,0,.45) }
.body{ display:grid; gap:6px; }
.serif { font-family: "Cormorant Garamond", serif; }
.status{
  display:inline-block; font-size:13px; padding:2px 8px; border-radius:999px;
  background: rgba(0,0,0,.06); color: rgba(0,0,0,.75);
  width: fit-content;
}
.title{ font-size:22px; line-height:1.2; margin-top:2px; }
.dates{ font-size:14px; opacity:.8; }
.artist{ font-size:15px; }
.a{ color:inherit; text-decoration:underline; cursor:pointer; }
.actions{ margin-top:6px; }
</style>
