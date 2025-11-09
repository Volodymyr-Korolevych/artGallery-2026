-- TASK-015: додати прив’язку замовлення до виставки
alter table if exists public.ticket_orders
  add column if not exists "exhibitionId" bigint;

do $$
begin
  -- FK якщо ще немає
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.ticket_orders'::regclass
      and conname = 'ticket_orders_exhibitionid_fkey'
  ) then
    alter table public.ticket_orders
      add constraint ticket_orders_exhibitionid_fkey
      foreign key ("exhibitionId") references public.exhibitions(id) on delete set null;
  end if;
end $$;

-- Індекси для швидкого фільтрування
create index if not exists idx_ticket_orders_exhibitionId on public.ticket_orders("exhibitionId");
create index if not exists idx_ticket_orders_createdAt on public.ticket_orders("createdAt");

-- Примітка: вважаємо, що у ticket_orders є поля:
-- id (bigserial), userId (uuid), categoryId (bigint), quantity (int),
-- amount (numeric), createdAt (timestamptz default now()), isActive (boolean default true)
