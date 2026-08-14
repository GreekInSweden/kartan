-- ============================================================
-- Kartan — Göteborg och omnejd, omgång 8
-- Källa: Wikipedia (infobox-koordinater), gunneboslott.se (officiell GPS).
-- Kör EFTER 048_seed_goteborg_7.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Göteborg — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Gunnebo slott?', 57.6583, 12.0625, 1.0, 'Mölndal, mellan sjöarna Stensjön och Rådasjön — nyklassicistiskt 1700-talsslott, ritat av Carl Wilhelm Carlberg'),
    ('Var ligger Göteborgs botaniska trädgård?', 57.6808, 11.9546, 0.6, 'Änggården — 175 hektar, en av Europas största botaniska trädgårdar, invigd 1923'),
    ('Var ligger Trädgårdsföreningen?', 57.705, 11.975, 0.4, 'Mitt i centrum, intill Avenyn — anlagd 1842, känd för sitt rosarium och Palmhuset')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
