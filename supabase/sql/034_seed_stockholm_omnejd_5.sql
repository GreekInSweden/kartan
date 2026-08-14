-- ============================================================
-- Kartan — Stockholm och omnejd, omgång 5
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 033_seed_stockholm_omnejd_4.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Stockholm — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Vaxholms fästning?', 59.40306, 18.35972, 1.5, 'Vaxholmen i Stockholms skärgård — byggd av Gustav Vasa 1548 för att försvara Stockholm'),
    ('Var ligger utsiktsplatsen Fjällgatan?', 59.3174, 18.0865, 0.5, 'Södermalm — en av Stockholms mest kända vyer över Gamla stan och Saltsjön')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
