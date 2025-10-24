create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'user',
  created_at timestamp with time zone default now()
);

create table if not exists artists (
  id bigserial primary key,
  fullName text not null,
  bio text,
  birthYear int,
  country text,
  portraitUrl text,
  slug text unique not null,
  isPublished boolean default true
);

create table if not exists exhibitions (
  id bigserial primary key,
  title text not null,
  slug text unique not null,
  description text,
  startDate date,
  endDate date,
  coverUrl text,
  status text check (status in ('current','past','upcoming')),
  painterId bigint references artists(id) on delete set null,
  isPublished boolean default true,
  createdAt timestamp with time zone default now()
);

create table if not exists artworks (
  id bigserial primary key,
  title text not null,
  artistId bigint references artists(id) on delete set null,
  exhibitionId bigint references exhibitions(id) on delete set null,
  year int,
  imageUrl text,
  description text,
  isPublished boolean default true
);

create table if not exists ticket_categories (
  id bigserial primary key,
  name text not null,
  price numeric not null check (price >= 0),
  isActive boolean default true,
  "order" int default 0
);

create table if not exists ticket_orders (
  id bigserial primary key,
  userId uuid not null references auth.users(id) on delete cascade,
  categoryId bigint not null references ticket_categories(id),
  amount int not null check (amount > 0),
  qrCode text,
  createdAt timestamp with time zone default now()
);
