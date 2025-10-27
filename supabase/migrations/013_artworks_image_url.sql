do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name='artworks' and column_name='imageurl'
  ) then
    execute 'alter table artworks add column "imageUrl" text';
  end if;
end $$;
