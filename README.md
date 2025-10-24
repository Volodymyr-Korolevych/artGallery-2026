# Art Gallery 2026 (Nuxt 3 + Supabase + Vuetify)

Готовий дипломний проєкт: галерея з поточною/минулою/майбутньою експозиціями, художниками, роботами та купівлею квитків.

## 1) Швидкий старт

```bash
pnpm i   # або npm i / yarn
cp .env.example .env
# встав NUXT_PUBLIC_SUPABASE_URL та NUXT_PUBLIC_SUPABASE_ANON_KEY
pnpm dev
```

## 2) Налаштування Supabase

1. Створи проєкт в Supabase (вже є у тебе).  
2. В консолі SQL виконай **migrations/001_schema.sql** та **migrations/002_policies.sql**.  
3. Створи запис у `profiles` з твоїм `id` (auth.users) і `role='admin'`.

## 3) Ролі та безпека (RLS)

- Всі таблиці з RLS: публічні читаються якщо `isPublished=true`;  
- Адмін (`profiles.role='admin'`) має повні права на CRUD;  
- Замовлення квитків: користувач бачить лише свої (`userId = auth.uid()`); адмін бачить усі.

## 4) Деплой на Vercel

- Підключи репозиторій GitHub.  
- Додай Environment variables: `NUXT_PUBLIC_SUPABASE_URL`, `NUXT_PUBLIC_SUPABASE_ANON_KEY`.  
- Build command: `npm run build`, Output: `.output/public` (Nuxt auto).

## 5) Сторінки

- `/` — Поточна експозиція  
- `/exhibitions/current|past|upcoming|[slug]`  
- `/artists`, `/artists/[slug]`  
- `/tickets`  
- `/login`  
- `/admin/...` (захищено middleware)

## 6) Тестові дані

Використай `INSERT` у `migrations/003_seed.sql` (наведено приклади).

## 7) Примітки

- QR коди зберігаються як dataURL у `ticket_orders.qrCode`.  
- У продакшені радимо зберігати в Storage і кешувати — тут простий варіант для диплома.
