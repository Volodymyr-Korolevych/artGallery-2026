-- Re-create RLS policies referencing quoted camelCase columns

drop policy if exists "public read artists" on artists;
drop policy if exists "public read exhibitions" on exhibitions;
drop policy if exists "public read artworks" on artworks;
drop policy if exists "public read ticket categories" on ticket_categories;
drop policy if exists "admin all artists" on artists;
drop policy if exists "admin all exhibitions" on exhibitions;
drop policy if exists "admin all artworks" on artworks;
drop policy if exists "admin all ticket categories" on ticket_categories;
drop policy if exists "orders select own" on ticket_orders;
drop policy if exists "orders insert own" on ticket_orders;
drop policy if exists "orders update own" on ticket_orders;
drop policy if exists "orders admin all" on ticket_orders;

create policy "public read artists" on artists
  for select using ( "isPublished" );

create policy "public read exhibitions" on exhibitions
  for select using ( "isPublished" );

create policy "public read artworks" on artworks
  for select using ( "isPublished" );

create policy "public read ticket categories" on ticket_categories
  for select using ( "isActive" );

create policy "admin all artists" on artists
  for all using ( is_admin() );

create policy "admin all exhibitions" on exhibitions
  for all using ( is_admin() );

create policy "admin all artworks" on artworks
  for all using ( is_admin() );

create policy "admin all ticket categories" on ticket_categories
  for all using ( is_admin() );

create policy "orders select own" on ticket_orders
  for select using ( "userId" = auth.uid() );

create policy "orders insert own" on ticket_orders
  for insert with check ( "userId" = auth.uid() );

create policy "orders update own" on ticket_orders
  for update using ( "userId" = auth.uid() );

create policy "orders admin all" on ticket_orders
  for all using ( is_admin() );
