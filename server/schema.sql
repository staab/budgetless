create table if not exists account (
  id uuid primary key,
  created timestamp not null default now(),
  email text not null UNIQUE,
  balance integer not null DEFAULT 0,
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

create table if not exists transaction (
  id uuid primary key,
  created timestamp not null default now(),
  transaction_date date not null,
  authorized_date date,
  account uuid not null,
  name text not null,
  transaction_type text not null,
  payment_channel text not null,
  amount integer not null,
  pending boolean not null,
  categories jsonb not null,
  plaid_transaction_id text not null unique,
  plaid_account_id text not null,
  plaid_category_id text not null
);
