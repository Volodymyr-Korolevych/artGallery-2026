create table if not exists contact_messages (
  id bigserial primary key,
  "name" text not null,
  "email" text not null,
  "message" text not null,
  "createdAt" timestamp with time zone default now()
);

alter table contact_messages enable row level security;

create policy "contact insert public" on contact_messages
  for insert with check ( true );

create policy "contact admin read" on contact_messages
  for select using ( is_admin() );
