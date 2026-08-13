-- ============================================================
-- Kartan — återställer det som rullades tillbaka från 026
-- (Supabase SQL Editor kör hela skriptet som EN transaktion —
-- när funktionsdelen kraschade rullades ÄVEN tabellerna tillbaka,
-- trots att de stod tidigare i skriptet). 027 fixade bara
-- funktionen (som redan fanns separat sen 001), inte det här.
-- Allt nedan är skrivet för att vara säkert att köra flera gånger.
-- ============================================================

create table if not exists kartan_paket (
  id uuid primary key default gen_random_uuid(),
  namn text not null,
  status text not null default 'utkast' check (status in ('utkast', 'publicerad')),
  skapad_at timestamptz not null default now()
);

create table if not exists kartan_paket_rundor (
  paket_id uuid not null references kartan_paket(id) on delete cascade,
  runda_id uuid not null references kartan_rundor(id) on delete cascade,
  ordning integer not null,
  primary key (paket_id, runda_id)
);

create table if not exists kartan_paket_resultat (
  id uuid primary key default gen_random_uuid(),
  paket_id uuid not null references kartan_paket(id) on delete cascade,
  spelare_id uuid not null,
  total_poang integer not null default 0,
  antal_ratt integer not null default 0,
  antal_besvarade integer not null default 0,
  avslutad_at timestamptz,
  skapad_at timestamptz not null default now(),
  unique (paket_id, spelare_id)
);

alter table kartan_paket enable row level security;
alter table kartan_paket_rundor enable row level security;
alter table kartan_paket_resultat enable row level security;

drop policy if exists "Läs publicerade paket" on kartan_paket;
create policy "Läs publicerade paket" on kartan_paket
  for select using (status = 'publicerad');

drop policy if exists "Läs rundor i publicerade paket" on kartan_paket_rundor;
create policy "Läs rundor i publicerade paket" on kartan_paket_rundor
  for select using (
    exists (select 1 from kartan_paket p where p.id = paket_id and p.status = 'publicerad')
  );

-- Säkerhetsfixen: stäng den öppna läs-policyn på kartan_rundor
-- (exponerade facit-kolumner) och peka klienten på en begränsad vy.
drop policy if exists "Läs rundor" on kartan_rundor;

create or replace view kartan_rundor_public as
select id, kategori_id, titel, typ, is_aktiv, skapad_at
from kartan_rundor;

grant select on kartan_rundor_public to anon, authenticated;

-- Bekräfta att allt finns nu:
select 'kartan_paket' as tabell, count(*) from kartan_paket
union all
select 'kartan_paket_rundor', count(*) from kartan_paket_rundor
union all
select 'kartan_paket_resultat', count(*) from kartan_paket_resultat;
