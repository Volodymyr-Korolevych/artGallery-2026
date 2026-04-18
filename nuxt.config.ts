// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: ['@nuxtjs/supabase', '@nuxtjs/tailwindcss'],
  runtimeConfig: {
    public: {
      appName: 'Art Gallery 2026'
    }
  },
  css: ['@/assets/styles/theme.css'],
  build: {
    transpile: ['@vuepic/vue-datepicker']
  },
  supabase: {
    redirect: false
  },
  tailwindcss: {
    configPath: 'tailwind.config.js',
    exposeConfig: false,
  }
})
