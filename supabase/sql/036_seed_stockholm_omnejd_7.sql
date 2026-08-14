-- ============================================================
-- Kartan — Stockholm och omnejd, omgång 7
-- 3Arena (tidigare Tele2 Arena) — ligger nära Avicii Arena/Globen
-- men är en annan fråga: att veta VAR det runda huset ligger är
-- inte samma kunskap som att veta var fotbollsarenan ligger.
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 035_seed_stockholm_omnejd_6.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Stockholm — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger 3Arena (f.d. Tele2 Arena), hemmaplan för Djurgården och Hammarby?', 59.29081, 18.08534, 0.6, 'Johanneshov — bytte namn från Tele2 Arena till 3Arena 2025, granne med Avicii Arena')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
