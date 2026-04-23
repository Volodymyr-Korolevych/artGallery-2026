/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './app.vue',
    './components/**/*.{vue,js,ts}',
    './layouts/**/*.{vue,js,ts}',
    './pages/**/*.{vue,js,ts}',
    './composables/**/*.{js,ts}',
    './plugins/**/*.{js,ts}',
    './utils/**/*.{js,ts}',
    './error.vue'
  ],

  theme: {
    extend: {
      colors: {
        ink: '#2f3a45',
        'ink-soft': '#5b6773',
        'surface-muted': '#f5f5f4',
        line: '#d6d3d1',
        accent: '#7c8a96'
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        serif: ['Cormorant Garamond', 'Georgia', 'serif']
      },
      maxWidth: {
        container: '1200px'
      },
      boxShadow: {
        soft: '0 8px 30px rgba(47, 58, 69, 0.08)'
      },
      letterSpacing: {
        wideish: '0.08em'
      },
      borderRadius: {
        soft: '2px'
      }
    }
  },

  plugins: []
}