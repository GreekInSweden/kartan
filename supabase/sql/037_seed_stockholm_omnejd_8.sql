-- ============================================================
-- Kartan — Stockholm och omnejd, omgång 8
-- Kungsträdgården — samma omprövning som 3Arena: nära Kungliga
-- Operan geografiskt, men ett välkänt namn i sig, oberoende av
-- exakt läge relativt grannarna.
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 036_seed_stockholm_omnejd_7.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Stockholm — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Kungsträdgården?', 59.33056, 18.07333, 0.5, 'Ett av Stockholms mest kända torg och parker — namnet betyder just ''kungens trädgård''')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
