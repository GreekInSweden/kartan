-- ============================================================
-- Kartan — Stockholm och omnejd, omgång 2
-- Bredare urval än bara museer/sevärdheter: nöjespark, sportarena,
-- vardagligt köpcentrum i grannkommunen Solna.
-- Källa: Wikipedia (infobox-koordinater).
-- Lägger till i SAMMA kategori som 030 ("Stockholm — landmärken")
-- istället för att skapa en ny — håller temapaketet samlat.
-- Kör EFTER 030_seed_stockholm_landmarken.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Stockholm — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Gröna Lund?', 59.32333, 18.09667, 0.5, 'Djurgården — Sveriges äldsta och mest kända nöjespark, öppnad 1883'),
    ('Var ligger Strawberry Arena (f.d. Friends Arena)?', 59.3725, 18.0, 1.0, 'Arenastaden, Solna — Sveriges nationalarena för fotboll, cirka 6 km norr om city'),
    ('Var ligger Solna Centrum?', 59.359972, 17.998, 0.8, 'Solna — köpcentrum och tunnelbanestation, känd för sin röda bergsdekor i taket')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
