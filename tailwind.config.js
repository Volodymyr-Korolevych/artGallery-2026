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
        ink: '#243f58',
        'ink-soft': '#4f6475',
        'ink-muted': '#738390',
        surface: '#fffefa',
        'surface-soft': '#f6f5ef',
        line: 'rgba(49, 91, 125, 0.24)',
        accent: '#315b7d',
        'accent-hover': '#244a68',
        'accent-soft': '#e4edf3'
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        serif: ['Cormorant Garamond', 'Georgia', 'serif']
      },
      maxWidth: {
        container: '1240px'
      },
      boxShadow: {
        soft: '0 8px 24px rgba(36, 63, 88, 0.09)',
        card: '0 14px 34px rgba(36, 63, 88, 0.11)'
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