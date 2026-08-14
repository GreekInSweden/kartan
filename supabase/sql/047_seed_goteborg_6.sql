-- ============================================================
-- Kartan — Göteborg och omnejd, omgång 6
-- Källa: Wikipedia (Älvsborgsbron/Old Älvsborg-artikeln), kartbilder.se.
-- Röda Sten: ingen egen exakt koordinat hittad, men artikeln
-- beskriver den som "en couple hundra meter" från Älvsborgsbrons
-- södra pylon/Old Älvsborg-ruinerna — den koordinaten används som
-- en dokumenterat nära approximation, med bredare tolerans (0,6 km)
-- för att kompensera ärligt.
-- Kviberg, Skatås, Mölndals sjukhus och färjeläget Lilla Varholmen
-- väntar fortfarande — hittade inga tillförlitliga koordinater.
-- Kör EFTER 046_seed_goteborg_5.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Göteborg — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Röda Sten konsthall?', 57.68972, 11.90722, 0.6, 'Klippan, vid Älvsborgsbrons södra fäste — konsthall i ett gammalt pannhus, känd för sin graffitivägg'),
    ('Var ligger Östra sjukhuset?', 57.721838, 12.049796, 1.0, 'Del av Sahlgrenska Universitetssjukhuset — bland annat regionens psykiatriska akutmottagning')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
