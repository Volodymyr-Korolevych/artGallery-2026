-- make delete in images bucket admin-only
drop policy if exists "images auth delete" on storage.objects;
drop policy if exists "images admin delete" on storage.objects;
create policy "images admin delete"
on storage.objects for delete
using (bucket_id = 'images' and is_admin());
