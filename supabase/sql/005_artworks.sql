create table if not exists public.artworks (
  id bigserial primary key,
  exhibitionId bigint not null references public.exhibitions(id) on delete cascade,
  artistId bigint references public.artists(id) on delete set null,
  title text not null,
  year int,
  description text,
  slot int not null check (slot between 1 and 6),
  imageUrl text,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

create unique index if not exists artworks_exh_slot_uidx
  on public.artworks(exhibitionId, slot);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new."updatedAt" = now();
  return new;
end $$;

drop trigger if exists set_artworks_updated_at on public.artworks;
create trigger set_artworks_updated_at
  before update on public.artworks
  for each row execute function public.set_updated_at();

alter table public.artworks enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies p
    where p.schemaname='public' and p.tablename='artworks' and p.policyname='artworks read'
  ) then
    create policy "artworks read" on public.artworks
      for select using (true);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies p
    where p.schemaname='public' and p.tablename='artworks' and p.policyname='artworks write'
  ) then
    create policy "artworks write" on public.artworks
      for all using (auth.role() = 'authenticated')
      with check (auth.role() = 'authenticated');
  end if;
end $$;
