-- ============================================================
-- Kartan — Göteborg och omnejd, omgång 11 (landar exakt på 30)
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 051_seed_goteborg_10.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Göteborg — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Göteborgs konstmuseum?', 57.69639, 11.98056, 0.4, 'Götaplatsen — Sveriges tredje största konstmuseum, mest känt för sin nordiska konst')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
