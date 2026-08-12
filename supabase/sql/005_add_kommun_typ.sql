-- ============================================================
-- Kartan — lägger till "kommun" som tredje speltyp (utöver "lan" och "punkt")
-- Kör EFTER 001-004, FÖRE 006_seed_kommun_innehall.sql
-- ============================================================

-- Tillåt typ='kommun' på kategorier
alter table kartan_kategorier drop constraint if exists kartan_kategorier_typ_check;
alter table kartan_kategorier add constraint kartan_kategorier_typ_check
  check (typ in ('lan', 'kommun', 'punkt'));

-- Tillåt typ='kommun' på rundor, och uppdatera facit-konsekvens-kollen så att
-- både 'lan' och 'kommun' använder ratt_plats_id (precis som 'lan' redan gjorde)
alter table kartan_rundor drop constraint if exists kartan_rundor_typ_check;
alter table kartan_rundor add constraint kartan_rundor_typ_check
  check (typ in ('lan', 'kommun', 'punkt'));

alter table kartan_rundor drop constraint if exists ratt_svar_konsekvent;
alter table kartan_rundor add constraint ratt_svar_konsekvent check (
  (typ in ('lan', 'kommun') and ratt_plats_id is not null and ratt_lat is null and ratt_lon is null)
  or
  (typ = 'punkt' and ratt_plats_id is null and ratt_lat is not null and ratt_lon is not null)
);

-- Uppdatera submit_kartan_guess: 'kommun' hanteras identiskt med 'lan'
-- (jämför plats_id direkt), bara 'punkt' skiljer sig (avståndsberäkning).
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
