do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name='exhibitions' and column_name='cardurl'
  ) then
    execute 'alter table exhibitions add column "cardUrl" text';
  end if;
end $$;
