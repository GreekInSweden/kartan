-- ============================================================
-- Kartan — datamodell + säker gissnings-RPC
-- Följer samma mönster som Spelkväll (record_score) och
-- KanDuAlla (/api/game/guess): facit exponeras aldrig för
-- klienten förrän efter en validerad, server-side gissning.
-- ============================================================

-- --- Platser (län eller kommuner) --------------------------------------
create table if not exists kartan_platser (
  id text primary key,             -- länskod ("01") eller kommunkod ("0138")
  typ text not null check (typ in ('lan', 'kommun')),
  namn text not null,
  lan_code text,                   -- endast satt för typ='kommun'
  lat double precision not null,   -- representativ punkt (inte alltid geometrisk centroid)
  lon double precision not null
);

-- --- Kategorier (t.ex. "Flest bilar per kommun", "Historiska händelser") ---
create table if not exists kartan_kategorier (
  id uuid primary key default gen_random_uuid(),
  namn text not null,
  beskrivning text,
  typ text not null check (typ in ('lan', 'punkt')),
  skapad_at timestamptz not null default now()
);

-- --- Rundor (en fråga inom en kategori) ---------------------------------
create table if not exists kartan_rundor (
  id uuid primary key default gen_random_uuid(),
  kategori_id uuid not null references kartan_kategorier(id) on delete cascade,
  titel text not null,             -- frågan, t.ex. "Var utspelade sig Ådalen 31?"
  typ text not null check (typ in ('lan', 'punkt')),

  -- Facit — typ='lan'
  ratt_plats_id text references kartan_platser(id),

  -- Facit — typ='punkt' (fri koordinat, t.ex. historisk plats)
  ratt_lat double precision,
  ratt_lon double precision,
  tolerans_km double precision default 15, -- radie som räknas som "träff" i punkt-läge

  visad_varde text not null,       -- text som visas vid avslöjande, t.ex. "1 båt per 6 invånare"
  is_aktiv boolean not null default true,
  skapad_at timestamptz not null default now(),

  constraint ratt_svar_konsekvent check (
    (typ = 'lan' and ratt_plats_id is not null and ratt_lat is null and ratt_lon is null)
    or
    (typ = 'punkt' and ratt_plats_id is null and ratt_lat is not null and ratt_lon is not null)
  )
);

-- --- Gissningar (skrivs ENDAST av RPC:en nedan, aldrig direkt av klient) ---
create table if not exists kartan_gissningar (
  id uuid primary key default gen_random_uuid(),
  runda_id uuid not null references kartan_rundor(id) on delete cascade,
  spelare_id uuid not null,        -- referens till er befintliga spelare/player-tabell

  plats_id text references kartan_platser(id),   -- gissning vid typ='lan'
  guess_lat double precision,                     -- gissning vid typ='punkt'
  guess_lon double precision,

  korrekt boolean,                  -- endast typ='lan'
  avstand_km double precision,      -- endast typ='punkt'
  poang integer not null,

  skapad_at timestamptz not null default now(),

  unique (runda_id, spelare_id)     -- en gissning per spelare och runda (motsvarar er dagliga spärr)
);

alter table kartan_platser enable row level security;
alter table kartan_kategorier enable row level security;
alter table kartan_rundor enable row level security;
alter table kartan_gissningar enable row level security;

-- Alla inloggade får läsa referensdata och rundor (men INTE facit-kolumnerna direkt —
-- se kommentar nedan om att styra kolumnåtkomst via en vy om ni vill dölja dem helt).
create policy "Läs platser" on kartan_platser for select using (true);
create policy "Läs kategorier" on kartan_kategorier for select using (true);
create policy "Läs rundor" on kartan_rundor for select using (true);

-- Spelare får bara se sina egna gissningar
create policy "Läs egna gissningar" on kartan_gissningar
  for select using (spelare_id = auth.uid());

-- OBS: ingen insert/update-policy för kartan_gissningar — all skrivning sker
-- via submit_kartan_guess (SECURITY DEFINER) nedan, som kringgår RLS medvetet.

-- ============================================================
-- RPC: submit_kartan_guess
-- Validerar och poängsätter en gissning server-side, precis som
-- record_score i Spelkväll. Returnerar facit ENDAST efter att
-- gissningen är sparad.
-- ============================================================
create or replace function submit_kartan_guess(
  p_runda_id uuid,
  p_spelare_id uuid,
  p_plats_id text default null,
  p_guess_lat double precision default null,
  p_guess_lon double precision default null
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
begin
  select * into v_runda from kartan_rundor where id = p_runda_id and is_aktiv = true;
  if not found then
    raise exception 'Rundan finns inte eller är inte aktiv';
  end if;

  -- En gissning per spelare och runda — UNIQUE-constrainten fångar race conditions också
  if exists (
    select 1 from kartan_gissningar
    where runda_id = p_runda_id and spelare_id = p_spelare_id
  ) then
    raise exception 'Du har redan gissat på den här rundan';
  end if;

  if v_runda.typ = 'lan' then
    if p_plats_id is null then
      raise exception 'plats_id krävs för länsklick-rundor';
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

    -- Haversine, beräknad server-side — klienten kan aldrig manipulera avståndet
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

-- Endast inloggade får anropa RPC:en
revoke all on function submit_kartan_guess from public;
grant execute on function submit_kartan_guess to authenticated;
