-- ============================================================
-- Kartan — Göteborg och omnejd, omgång 7
-- Källa: worldofvolvo.com (officiella GPS-koordinater), Wikipedia.
-- Kör EFTER 047_seed_goteborg_6.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Göteborg — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger World of Volvo?', 57.69, 11.9972, 0.4, 'Vid Lisebergs entré — Volvos upplevelsecenter, öppnat 2024 efter det gamla Volvomuseet')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
