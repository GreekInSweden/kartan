-- ============================================================
-- Kartan — Göteborg och omnejd, omgång 5
-- Källa: Wikipedia (infobox-koordinater).
-- Kviberg, Skatås, Röda Sten och färjeläget mot Öckerö väntar
-- till nästa omgång — hittade inga exakta koordinater för dem
-- den här gången, valde att inte gissa.
-- Kör EFTER 045_seed_goteborg_4.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Göteborg — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Frölunda Torg?', 57.65194, 11.91167, 1.0, 'Västra Frölunda — ett av Skandinaviens största köpcentrum, invigt 1966 av Olof Palme'),
    ('Var ligger Delsjön?', 57.68472, 12.04583, 1.0, 'Östra Göteborg — egentligen två sjöar, Stora och Lilla Delsjön, med en av stadens populäraste badplatser'),
    ('Var ligger Sahlgrenska Universitetssjukhuset?', 57.6833, 11.955, 0.8, 'Sveriges största sjukhus, cirka 17 000 anställda — en av tre delar (med Östra och Mölndal)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
