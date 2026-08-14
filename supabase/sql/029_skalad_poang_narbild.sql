-- ============================================================
-- Kartan — poängformel som skalar med rundans tolerans
-- Tidigare hade ALLA nålgissnings-rundor samma "förlåtande" kurva
-- (decay=120 km), vilket funkade för Sverige-i-stort men gör att
-- ett missat gissning på 5 km i en stad fortfarande ger nästan
-- full poäng — helt fel känsla för täta stadspaket.
--
-- Nu härleds decay-värdet från rundans egen tolerans_km (samma
-- förhållande som tidigare: decay = tolerans × 6, vilket återger
-- exakt samma kurva som innan för landsomfattande frågor, men blir
-- mycket strängare för stadsnära frågor med liten tolerans).
-- Kör EFTER 001-028.
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
  v_decay_km double precision;
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

    -- Skalad decay: samma förhållande (×6) som tidigare hårdkodade
    -- 120/20 gav för landsomfattande frågor, men följer nu rundans
    -- egen tolerans_km istället för ett fast tal. Golv på 3 km så
    -- extremt tighta frågor inte blir orimligt hårda.
    v_decay_km := greatest(v_runda.tolerans_km, 3) * 6;
    v_poang := greatest(0, least(1000, round(1000 * exp(-v_avstand_km / v_decay_km))::integer));
    v_ratt_lat := v_runda.ratt_lat;
    v_ratt_lon := v_runda.ratt_lon;

    insert into kartan_gissningar (runda_id, spelare_id, guess_lat, guess_lon, avstand_km, poang)
    values (p_runda_id, p_spelare_id, p_guess_lat, p_guess_lon, v_avstand_km, v_poang);
  end if;

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
