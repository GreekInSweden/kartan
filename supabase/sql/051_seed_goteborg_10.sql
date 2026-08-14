-- ============================================================
-- Kartan — Göteborg och omnejd, omgång 10
-- Källa: Wikipedia/Wikidata (infobox-koordinater).
-- Kör EFTER 050_seed_goteborg_9.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Göteborg — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger New Älvsborg (Nya Älvsborgs fästning)?', 57.685, 11.83889, 0.8, 'En egen ö ute i älvfjorden, cirka 12 km från Röda Sten/Gamla Älvsborg — aldrig intagen av fiender trots flera belägringar'),
    ('Var ligger Aeroseum?', 57.7708, 11.8806, 0.8, 'Säve, norr om Göteborg — flygmuseum i ett hemligstämplat, 22 000 kvm stort bergrum från kalla kriget'),
    ('Var ligger Röhsska museet?', 57.7, 11.97333, 0.4, 'Sveriges enda specialmuseum för design och konsthantverk, öppnat 1916')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
