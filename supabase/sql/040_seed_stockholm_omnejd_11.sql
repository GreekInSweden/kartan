-- ============================================================
-- Kartan — Stockholm och omnejd, omgång 11 (slutomgång -> 30 st)
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 039_seed_stockholm_omnejd_10.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Stockholm — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Bällsta bro?', 59.36028, 17.96083, 0.7, 'Gränsen mellan Sundbybergs kommun och Bromma — bro på platsen sedan 1690'),
    ('Var ligger Norra begravningsplatsen?', 59.35667, 18.01917, 1.0, 'Solna — vilostad för bland andra Per Albin Hansson och flera Nobelpristagare'),
    ('Var ligger Tranebergsbron?', 59.335926, 17.985701, 1.0, 'Förbinder Kungsholmen med Bromma över Tranebergssund — invigd 1934'),
    ('Var ligger Vasaparken?', 59.3401, 18.0429, 0.5, 'Vasastan — Astrid Lindgren bodde vid parken, som nämns i flera av hennes böcker')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
