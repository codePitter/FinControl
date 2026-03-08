-- Ejecutar en Supabase SQL Editor

create table if not exists user_data (
  id          uuid primary key references auth.users(id) on delete cascade,
  data        jsonb not null default '{}',
  updated_at  timestamptz not null default now()
);

alter table user_data enable row level security;

drop policy if exists "user_data_select" on user_data;
drop policy if exists "user_data_insert" on user_data;
drop policy if exists "user_data_update" on user_data;
drop policy if exists "user_data_delete" on user_data;

create policy "user_data_select" on user_data for select using (auth.uid() = id);
create policy "user_data_insert" on user_data for insert with check (auth.uid() = id);
create policy "user_data_update" on user_data for update using (auth.uid() = id);
create policy "user_data_delete" on user_data for delete using (auth.uid() = id);

create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_updated_at_user_data on user_data;
create trigger set_updated_at_user_data
  before update on user_data
  for each row execute procedure update_updated_at_column();