do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name='artists' and column_name='portraiturl'
  ) then
    execute 'alter table artists add column "portraitUrl" text';
  end if;
end $$;
