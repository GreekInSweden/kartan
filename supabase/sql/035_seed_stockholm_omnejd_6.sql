-- ============================================================
-- Kartan — Stockholm och omnejd, omgång 6
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 034_seed_stockholm_omnejd_5.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Stockholm — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Kista Galleria?', 59.402722, 17.945139, 1.0, 'Kista, kallat ''Sveriges IT-centrum'' — ett av landets största köpcentrum norr om city')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
