-- ============================================================
-- Kartan — Stockholm och omnejd, omgång 12 (landar exakt på 30)
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 040_seed_stockholm_omnejd_11.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Stockholm — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Fotografiska?', 59.3178, 18.085, 0.4, 'Södermalm, vid vattnet nära Slussen — världens största museum för fotografi, öppnat 2010'),
    ('Var ligger Stockholms stadsbibliotek?', 59.3434, 18.0543, 0.5, 'Nära Odenplan — Gunnar Asplunds klassiska cylinderbyggnad, invigd 1928')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
