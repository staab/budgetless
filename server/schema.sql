create table if not exists account (
  id uuid primary key,
  created timestamp not null default now(),
  email text not null,
  login_code text,
  login_code_expires timestamp,
  plaid_access_token text,
  plaid_item_id text
);

create table if not exists session (
  id uuid primary key,
  created timestamp not null default now(),
  key text not null,
  account uuid not null
);
