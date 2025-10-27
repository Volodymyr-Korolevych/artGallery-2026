do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name='exhibitions' and column_name='startdate'
  ) then
    execute 'alter table exhibitions add column "startDate" timestamptz';
  end if;
  if not exists (
    select 1 from information_schema.columns
    where table_name='exhibitions' and column_name='enddate'
  ) then
    execute 'alter table exhibitions add column "endDate" timestamptz';
  end if;
end $$;
