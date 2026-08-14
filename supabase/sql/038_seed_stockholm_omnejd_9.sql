-- ============================================================
-- Kartan — Stockholm och omnejd, omgång 9
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 037_seed_stockholm_omnejd_8.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Stockholm — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Riddarholmskyrkan, kungarnas begravningskyrka?', 59.3246, 18.0645, 0.5, 'Riddarholmen, en liten ö i anslutning till Gamla stan — svenska monarker begravdes här fram till 1950'),
    ('Var ligger Moderna Museet?', 59.32583, 18.085, 0.5, 'Skeppsholmen — Sveriges nationalmuseum för modern konst, öppnat 1958')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
