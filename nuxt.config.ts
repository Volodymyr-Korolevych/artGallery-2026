// https://nuxt.com/docs/api/configuration/nuxt-config
import vuetify, { transformAssetUrls } from 'vite-plugin-vuetify'

export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: ['@nuxtjs/supabase'],
  runtimeConfig: {
    public: {
      appName: 'Art Gallery 2026'
    }
  },
  css: [
    '@/assets/styles/theme.css','vuetify/styles'],
  build: {
    transpile: ['vuetify']
  },
  vite: {
    ssr: {
      noExternal: ['vuetify']
    },
    plugins: [
      // @ts-ignore
      vuetify({ autoImport: true })
    ]
  },
  vue: {
    transformAssetUrls
  },
  supabase: {
    // keys will come from .env
    redirect: false
  }
})
