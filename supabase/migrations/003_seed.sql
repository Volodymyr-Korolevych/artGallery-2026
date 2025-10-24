insert into artists (fullName, bio, slug) values 
('Іван Приклад', 'Коротка біографія', 'ivan-pryklad')
on conflict do nothing;

insert into exhibitions (title, slug, description, status, painterId, isPublished)
select 'Сонячні дні', 'sonyachni-dni', 'Опис виставки', 'current', a.id, true
from artists a where a.slug='ivan-pryklad'
on conflict do nothing;

insert into ticket_categories (name, price, isActive, "order") values
('Дорослий', 200, true, 1),
('Студент', 100, true, 2),
('Пільговий', 50, true, 3)
on conflict do nothing;
