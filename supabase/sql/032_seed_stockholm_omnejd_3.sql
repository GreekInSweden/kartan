-- ============================================================
-- Kartan — Stockholm och omnejd, omgång 3
-- Södermalm (Slussen) + en av de finare förorterna (Djursholm,
-- Danderyd) — bredare geografisk spridning än bara innerstaden.
-- Källa: Wikipedia (infobox-koordinater).
-- Lägger till i samma kategori som 030/031.
-- Kör EFTER 031_seed_stockholm_omnejd.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Stockholm — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Slussen?', 59.31917, 18.07194, 0.5, 'Södermalm — historisk sluss och knutpunkt mellan Mälaren och Östersjön'),
    ('Var ligger Djursholms slott?', 59.4008, 18.0892, 1.2, 'Danderyds kommun — 1600-talsslott, numera kommunhus för Danderyd')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
