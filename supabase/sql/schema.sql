-- ====================================
-- IMS schema: categories, products, stock_audit, roles
-- ====================================

-- Categories
create table if not exists categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Products
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  sku text not null unique,
  name text not null,
  description text,
  price numeric(10,2) default 0,
  current_quantity integer default 0,
  min_stock integer default 0,
  category_id uuid references categories(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Stock audit
create table if not exists stock_audit (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete cascade,
  change_type text check (change_type in ('IN','OUT','ADJUST')),
  quantity integer not null,
  old_quantity integer,
  new_quantity integer,
  created_by uuid references auth.users(id),
  created_at timestamptz default now()
);

-- Role mapping table for app-level roles
create table if not exists app_user_roles (
  user_id uuid references auth.users(id) on delete cascade,
  role text not null,
  primary key (user_id)
);

-- Enable Row Level Security
alter table categories enable row level security;
alter table products enable row level security;
alter table stock_audit enable row level security;
alter table app_user_roles enable row level security;

-- Policies: authenticated users can read/write (we'll restrict later by role)
create policy if not exists "Authenticated users can read/write categories"
  on categories for all
  using (auth.role() = 'authenticated');

create policy if not exists "Authenticated users can read/write products"
  on products for all
  using (auth.role() = 'authenticated');

create policy if not exists "Authenticated users can read/write stock_audit"
  on stock_audit for all
  using (auth.role() = 'authenticated');

create policy if not exists "Authenticated users can read/write app_user_roles"
  on app_user_roles for all
  using (auth.role() = 'authenticated');
