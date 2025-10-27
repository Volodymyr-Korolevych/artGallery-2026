-- Add username to profiles if not exists
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name='profiles' and column_name='username'
  ) then
    execute 'alter table profiles add column "username" text';
  end if;
end $$;

-- helper to slugify username if empty; admin -> "адмін"
create or replace function ensure_profile_username(p_user uuid)
returns void language plpgsql as $$
declare
  v_is_admin boolean := false;
  v_uname text;
begin
  select coalesce(role='admin', false), nullif(username, '')
    into v_is_admin, v_uname
  from profiles where id = p_user;

  if v_uname is null then
    -- fallback from email prefix
    update profiles set "username" = split_part(email,'@',1)
    where id = p_user;
  end if;

  -- admin label override
  if v_is_admin then
    update profiles set "username" = 'адмін' where id = p_user;
  end if;
end; $$;

-- when profile is inserted (e.g., by existing auth trigger), ensure username
create or replace function trg_profiles_username()
returns trigger language plpgsql as $$
begin
  perform ensure_profile_username(new.id);
  return new;
end; $$;

drop trigger if exists trg_profiles_username_ins on profiles;
create trigger trg_profiles_username_ins
after insert on profiles
for each row execute procedure trg_profiles_username();

-- When clients set user_metadata.username during signUp, mirror it:
-- If you already have an auth -> profiles provisioning trigger, keep it.
-- Otherwise create a lightweight sync from auth.users on insert.
create or replace function handle_new_user()
returns trigger language plpgsql as $$
begin
  insert into profiles (id, email, "username", role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email,'@',1)),
    'user'
  )
  on conflict (id) do update
    set email = excluded.email,
        "username" = excluded."username";
  perform ensure_profile_username(new.id);
  return new;
end; $$;

-- Attach to auth.users only if no such trigger exists
do $$
begin
  if not exists (select 1 from pg_trigger where tgname='on_auth_user_created') then
    create trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure handle_new_user();
  end if;
end $$;

-- RLS: allow user to see own profile; admin sees all (assumes is_admin())
drop policy if exists "profiles select own" on profiles;
create policy "profiles select own" on profiles
  for select using ( id = auth.uid() or is_admin() );
drop policy if exists "profiles update own" on profiles;
create policy "profiles update own" on profiles
  for update using ( id = auth.uid() or is_admin() );
