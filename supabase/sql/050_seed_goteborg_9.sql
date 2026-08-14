-- ============================================================
-- Kartan — Göteborg och omnejd, omgång 9
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 049_seed_goteborg_8.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Göteborg — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Angered?', 57.783, 12.1, 1.5, '12 km norr om centrala Göteborg — ett av stadens mest omtalade förortsområden'),
    ('Var ligger Vinga fyr?', 57.63206, 11.60131, 1.5, 'Yttersta ön i Göteborgs skärgård — first tänd 1890, ledde sjöfarare till Göteborgs hamn i över ett sekel'),
    ('Var ligger Styrsö?', 57.617, 11.783, 1.0, 'En av de större öarna i Södra skärgården, nås med båt från Saltholmen')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
