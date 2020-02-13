create table if not exists access_requests (
  id uuid primary key,
  created timestamp not null default now(),
  email text not null
);
