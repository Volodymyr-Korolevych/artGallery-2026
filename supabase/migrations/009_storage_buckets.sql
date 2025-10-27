-- Create bucket if missing
insert into storage.buckets (id, name, public)
values ('images', 'images', true)
on conflict (id) do nothing;

-- Policies
create policy if not exists "images public read"
on storage.objects for select
using ( bucket_id = 'images' );

create policy if not exists "images auth write"
on storage.objects for insert
with check ( bucket_id = 'images' and auth.role() = 'authenticated' );

create policy if not exists "images auth update"
on storage.objects for update
using ( bucket_id = 'images' and auth.role() = 'authenticated' );

create policy if not exists "images auth delete own"
on storage.objects for delete
using ( bucket_id = 'images' and auth.role() = 'authenticated' and owner = auth.uid() );
