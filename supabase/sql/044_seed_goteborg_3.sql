-- ============================================================
-- Kartan — Göteborg och omnejd, omgång 3
-- Källa: Wikipedia (infobox-koordinater).
-- Universeum uteslöts medvetet — ligger bara ~60 m från Liseberg,
-- för nära för att vara en meningsfull egen fråga (till skillnad
-- från Globen/3Arena-fallet, som låg flera hundra meter isär).
-- Kör EFTER 043_seed_goteborg_2.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Göteborg — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Skansen Kronan?', 57.69667, 11.95472, 0.5, 'Haga, på höjden Risåsberget — 1600-talsfästning, aldrig anfallen trots sitt hotfulla utseende'),
    ('Var ligger Slottsskogen?', 57.68611, 11.93889, 0.7, '137 hektar stor stadspark, anlagd 1876 — hem till Barnens Zoo och pingviner'),
    ('Var ligger Kronhuset?', 57.70778, 11.96361, 0.4, 'Nordstaden — Göteborgs äldsta bevarade profana byggnad, uppförd 1643-1654'),
    ('Var ligger Feskekôrka?', 57.70111, 11.95778, 0.4, 'En fiskhall byggd 1874, kallad så för att den påminner om en nygotisk kyrka'),
    ('Var ligger Göteborgs stadsmuseum?', 57.70639, 11.96333, 0.4, 'Huserar i Ostindiska huset, byggt 1762 för Svenska Ostindiska Companiet')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
