<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin-only' })
onMounted(() => navigateTo('/admin/exhibitions'))
</script>
<template></template>
