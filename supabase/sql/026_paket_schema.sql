-- ============================================================
-- Kartan — Paket-mekanik (10 frågor per paket, 5 kommun + 5 nål)
-- Kör EFTER 001-025.
-- ============================================================

-- --- Paket ---------------------------------------------------
create table if not exists kartan_paket (
  id uuid primary key default gen_random_uuid(),
  namn text not null,
  status text not null default 'utkast' check (status in ('utkast', 'publicerad')),
  skapad_at timestamptz not null default now()
);

-- --- Vilka rundor ingår i paketet, och i vilken ordning -------
create table if not exists kartan_paket_rundor (
  paket_id uuid not null references kartan_paket(id) on delete cascade,
  runda_id uuid not null references kartan_rundor(id) on delete cascade,
  ordning integer not null,
  primary key (paket_id, runda_id)
);

-- --- Spelarens resultat för ett paket (summerad poäng) --------
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

-- Publika paket är läsbara av alla (även utan inloggning)
create policy "Läs publicerade paket" on kartan_paket
  for select using (status = 'publicerad');

create policy "Läs rundor i publicerade paket" on kartan_paket_rundor
  for select using (
    exists (select 1 from kartan_paket p where p.id = paket_id and p.status = 'publicerad')
  );

-- OBS: ingen select-policy för kartan_paket_resultat härifrån —
-- läses via /api/kartan/stats-mönstret (admin-klient) tills vidare,
-- precis som med kartan_gissningar.

-- ============================================================
-- SÄKERHETSFIX: kartan_rundor har hittills haft en öppen
-- select-policy (`using (true)`) som exponerade FACIT-kolumnerna
-- (ratt_plats_id, ratt_lat, ratt_lon) för vem som helst med
-- anon-nyckeln, även om appens UI aldrig valde ut dem. Det stänger
-- vi nu. Klienten läser istället en vy utan facit-kolumnerna.
-- ============================================================

drop policy if exists "Läs rundor" on kartan_rundor;
-- Ingen ersättande public select-policy på kartan_rundor —
-- all klientläsning sker via vyn nedan. Admin-rutter (som redan
-- använder den hemliga nyckeln) påverkas inte av RLS alls.

create or replace view kartan_rundor_public as
select id, kategori_id, titel, typ, is_aktiv, skapad_at
from kartan_rundor;

grant select on kartan_rundor_public to anon, authenticated;

-- ============================================================
-- Uppdaterad submit_kartan_guess: tar nu emot ett valfritt
-- p_paket_id. Om satt, summeras poängen i kartan_paket_resultat,
-- och paketet markeras avslutat när alla dess rundor är besvarade.
-- ============================================================
create or replace function submit_kartan_guess(
  p_runda_id uuid,
  p_spelare_id uuid,
  p_plats_id text default null,
  p_guess_lat double precision default null,
  p_guess_lon double precision default null,
  p_paket_id uuid default null
)
returns table (
  korrekt boolean,
  avstand_km double precision,
  poang integer,
  ratt_plats_id text,
  ratt_lat double precision,
  ratt_lon double precision,
  visad_varde text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_runda kartan_rundor%rowtype;
  v_ratt_lat double precision;
  v_ratt_lon double precision;
  v_avstand_km double precision;
  v_korrekt boolean;
  v_poang integer;
  v_paket_total_rundor integer;
  v_paket_besvarade integer;
begin
  select * into v_runda from kartan_rundor where id = p_runda_id and is_aktiv = true;
  if not found then
    raise exception 'Rundan finns inte eller är inte aktiv';
  end if;

  if exists (
    select 1 from kartan_gissningar
    where runda_id = p_runda_id and spelare_id = p_spelare_id
  ) then
    raise exception 'Du har redan gissat på den här rundan';
  end if;

  if v_runda.typ in ('lan', 'kommun') then
    if p_plats_id is null then
      raise exception 'plats_id krävs för lan/kommun-rundor';
    end if;

    v_korrekt := (p_plats_id = v_runda.ratt_plats_id);
    v_poang := case when v_korrekt then 1000 else 0 end;

    select lat, lon into v_ratt_lat, v_ratt_lon
    from kartan_platser where id = v_runda.ratt_plats_id;

    insert into kartan_gissningar (runda_id, spelare_id, plats_id, korrekt, poang)
    values (p_runda_id, p_spelare_id, p_plats_id, v_korrekt, v_poang);

  else -- typ = 'punkt'
    if p_guess_lat is null or p_guess_lon is null then
      raise exception 'guess_lat/guess_lon krävs för nålgissnings-rundor';
    end if;

    v_avstand_km := 6371 * 2 * asin(sqrt(
      sin(radians(v_runda.ratt_lat - p_guess_lat) / 2) ^ 2 +
      cos(radians(p_guess_lat)) * cos(radians(v_runda.ratt_lat)) *
      sin(radians(v_runda.ratt_lon - p_guess_lon) / 2) ^ 2
    ));

    v_poang := greatest(0, least(1000, round(1000 * exp(-v_avstand_km / 120))::integer));
    v_ratt_lat := v_runda.ratt_lat;
    v_ratt_lon := v_runda.ratt_lon;

    insert into kartan_gissningar (runda_id, spelare_id, guess_lat, guess_lon, avstand_km, poang)
    values (p_runda_id, p_spelare_id, p_guess_lat, p_guess_lon, v_avstand_km, v_poang);
  end if;

  -- Paket-bokföring: summera poäng, markera avslutat vid sista frågan
  if p_paket_id is not null then
    insert into kartan_paket_resultat (paket_id, spelare_id, total_poang, antal_ratt, antal_besvarade)
    values (p_paket_id, p_spelare_id, v_poang, case when v_korrekt then 1 else 0 end, 1)
    on conflict (paket_id, spelare_id) do update set
      total_poang = kartan_paket_resultat.total_poang + excluded.total_poang,
      antal_ratt = kartan_paket_resultat.antal_ratt + excluded.antal_ratt,
      antal_besvarade = kartan_paket_resultat.antal_besvarade + 1;

    select count(*) into v_paket_total_rundor
    from kartan_paket_rundor where paket_id = p_paket_id;

    select antal_besvarade into v_paket_besvarade
    from kartan_paket_resultat where paket_id = p_paket_id and spelare_id = p_spelare_id;

    if v_paket_besvarade >= v_paket_total_rundor then
      update kartan_paket_resultat set avslutad_at = now()
      where paket_id = p_paket_id and spelare_id = p_spelare_id and avslutad_at is null;
    end if;
  end if;

  return query select
    v_korrekt,
    v_avstand_km,
    v_poang,
    v_runda.ratt_plats_id,
    v_ratt_lat,
    v_ratt_lon,
    v_runda.visad_varde;
end;
$$;

revoke all on function submit_kartan_guess from public;
grant execute on function submit_kartan_guess to authenticated, anon;
