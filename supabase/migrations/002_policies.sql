-- Enable RLS
alter table profiles enable row level security;
alter table artists enable row level security;
alter table exhibitions enable row level security;
alter table artworks enable row level security;
alter table ticket_categories enable row level security;
alter table ticket_orders enable row level security;

-- helper function: is_admin()
create or replace function is_admin() returns boolean language sql security definer set search_path = public as $$
  select exists (select 1 from profiles where id = auth.uid() and role = 'admin');
$$;

-- profiles
create policy "read own profile" on profiles for select using ( id = auth.uid() );
create policy "upsert own profile" on profiles for insert with check ( id = auth.uid() );
create policy "admin read all profiles" on profiles for select using ( is_admin() );
create policy "admin update profiles" on profiles for update using ( is_admin() );

-- public read for published content
create policy "public read artists" on artists for select using ( isPublished );
create policy "public read exhibitions" on exhibitions for select using ( isPublished );
create policy "public read artworks" on artworks for select using ( isPublished );
create policy "public read ticket categories" on ticket_categories for select using ( isActive );

-- admin full access
create policy "admin all artists" on artists for all using ( is_admin() );
create policy "admin all exhibitions" on exhibitions for all using ( is_admin() );
create policy "admin all artworks" on artworks for all using ( is_admin() );
create policy "admin all ticket categories" on ticket_categories for all using ( is_admin() );

-- orders: user owns their rows; admin sees all
create policy "orders select own" on ticket_orders for select using ( userId = auth.uid() );
create policy "orders insert own" on ticket_orders for insert with check ( userId = auth.uid() );
create policy "orders update own" on ticket_orders for update using ( userId = auth.uid() );
create policy "orders admin all" on ticket_orders for all using ( is_admin() );
