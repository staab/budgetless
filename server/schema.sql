create table if not exists account (
  id uuid primary key,
  created timestamp not null default now(),
  email text not null,
  login_code text,
  login_code_expires timestamp
);

create table if not exists session (
  id uuid primary key,
  created timestamp not null default now(),
  key text not null,
  account uuid not null
);
