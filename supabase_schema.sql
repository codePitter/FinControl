-- ══════════════════════════════════════════════════════
-- FINCONTROL — Supabase Schema
-- Ejecutar en: Supabase Dashboard → SQL Editor
-- ══════════════════════════════════════════════════════

-- Tabla principal: un registro por usuario con todos sus datos en JSONB
create table if not exists user_data (
  id          uuid primary key references auth.users(id) on delete cascade,
  data        jsonb not null default '{}',
  updated_at  timestamptz default now()
);

-- Row Level Security: cada usuario solo ve y modifica sus propios datos
alter table user_data enable row level security;

create policy "Usuarios pueden leer sus datos"
  on user_data for select
  using (auth.uid() = id);

create policy "Usuarios pueden insertar sus datos"
  on user_data for insert
  with check (auth.uid() = id);

create policy "Usuarios pueden actualizar sus datos"
  on user_data for update
  using (auth.uid() = id);

create policy "Usuarios pueden eliminar sus datos"
  on user_data for delete
  using (auth.uid() = id);

-- Trigger para actualizar updated_at automáticamente
create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger set_updated_at
  before update on user_data
  for each row execute procedure update_updated_at();
