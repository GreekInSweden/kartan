-- ============================================================
-- Kartan — Göteborg och omnejd, omgång 2
-- Källa: Wikipedia (infobox-koordinater).
-- Lägger till i samma kategori som 042 ("Göteborg — landmärken").
-- Kör EFTER 042_seed_goteborg_1.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Göteborg — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Marstrand?', 57.883, 11.583, 1.0, 'Kungälvs kommun — Sveriges ''seglarhuvudstad'', med Carlstens fästning på öns högsta punkt'),
    ('Var ligger Kungälv?', 57.867, 11.967, 1.5, 'Vid Nordre älvs mynning — hem till Bohus fästning, en av Nordens bäst bevarade borgruiner'),
    ('Var ligger Göteborg Landvetter Airport?', 57.66, 12.29111, 2.0, 'Härryda kommun, cirka 25 km sydost om Göteborg — Sveriges näst största flygplats'),
    ('Var ligger Säve flygplats (f.d. Göteborg City Airport)?', 57.77556, 11.87056, 1.5, 'Hisingen, Göteborgs kommun — stängd för reguljärflyg 2015, tidigare bland annat Ryanair-bas')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
