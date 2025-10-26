-- Rename columns to quoted camelCase if they exist in lowercase.
do $$
begin
  -- artists
  if exists (select 1 from information_schema.columns where table_name='artists' and column_name='fullname') then
    execute 'alter table artists rename column fullName to "fullName"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='artists' and column_name='birthyear') then
    execute 'alter table artists rename column birthYear to "birthYear"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='artists' and column_name='portraiturl') then
    execute 'alter table artists rename column portraitUrl to "portraitUrl"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='artists' and column_name='ispublished') then
    execute 'alter table artists rename column isPublished to "isPublished"';
  end if;

  -- exhibitions
  if exists (select 1 from information_schema.columns where table_name='exhibitions' and column_name='coverurl') then
    execute 'alter table exhibitions rename column coverUrl to "coverUrl"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='exhibitions' and column_name='painterid') then
    execute 'alter table exhibitions rename column painterId to "painterId"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='exhibitions' and column_name='ispublished') then
    execute 'alter table exhibitions rename column isPublished to "isPublished"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='exhibitions' and column_name='createdat') then
    execute 'alter table exhibitions rename column createdAt to "createdAt"';
  end if;

  -- artworks
  if exists (select 1 from information_schema.columns where table_name='artworks' and column_name='artistid') then
    execute 'alter table artworks rename column artistId to "artistId"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='artworks' and column_name='exhibitionid') then
    execute 'alter table artworks rename column exhibitionId to "exhibitionId"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='artworks' and column_name='imageurl') then
    execute 'alter table artworks rename column imageUrl to "imageUrl"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='artworks' and column_name='ispublished') then
    execute 'alter table artworks rename column isPublished to "isPublished"';
  end if;

  -- ticket_categories
  if exists (select 1 from information_schema.columns where table_name='ticket_categories' and column_name='isactive') then
    execute 'alter table ticket_categories rename column isActive to "isActive"';
  end if;

  -- ticket_orders
  if exists (select 1 from information_schema.columns where table_name='ticket_orders' and column_name='userid') then
    execute 'alter table ticket_orders rename column userId to "userId"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='ticket_orders' and column_name='categoryid') then
    execute 'alter table ticket_orders rename column categoryId to "categoryId"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='ticket_orders' and column_name='qrcode') then
    execute 'alter table ticket_orders rename column qrCode to "qrCode"';
  end if;
  if exists (select 1 from information_schema.columns where table_name='ticket_orders' and column_name='createdat') then
    execute 'alter table ticket_orders rename column createdAt to "createdAt"';
  end if;
end $$;
