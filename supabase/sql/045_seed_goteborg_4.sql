-- ============================================================
-- Kartan — Göteborg och omnejd, omgång 4
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 044_seed_goteborg_3.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Göteborg — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Avenyn (Kungsportsavenyn)?', 57.6975, 11.97917, 0.5, 'Göteborgs paradgata, cirka 1 km lång — inspirerad av Champs-Élysées i Paris'),
    ('Var ligger Götaplatsen?', 57.6916, 11.9744, 0.4, 'Avenyns södra ände — Poseidonstatyn, konstmuseet och stadsbiblioteket ligger runt torget')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
