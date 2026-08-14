-- ============================================================
-- Kartan — Stockholm och omnejd, omgång 10
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 038_seed_stockholm_omnejd_9.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Stockholm — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Millesgården?', 59.358889, 18.121389, 1.0, 'Lidingö — skulptören Carl Milles forna hem och ateljé, numera museum och skulpturpark'),
    ('Var ligger Saltsjöbaden?', 59.28611, 18.28722, 2.0, 'Nacka kommun — badort byggd av bankiren Knut Agathon Wallenberg från 1891, djupt inne i skärgården')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
