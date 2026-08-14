-- ============================================================
-- Kartan — Stockholm och omnejd, omgång 4
-- Källa: Wikipedia (infobox-koordinater).
-- Lägger till i samma kategori som 030/031/032.
-- Kör EFTER 032_seed_stockholm_omnejd_3.sql.
-- ============================================================

with k as (
  select id from kartan_kategorier where namn = 'Stockholm — landmärken' limit 1
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Kaknästornet?', 59.335, 18.12639, 1.0, 'Ladugårdsgärdet — 155 meter högt telekommunikationstorn, invigt 1967'),
    ('Var ligger Medborgarplatsen?', 59.31431, 18.07361, 0.5, 'Södermalm — här höll Anna Lindh sitt sista offentliga tal 2003'),
    ('Var ligger Hammarby Sjöstad?', 59.3033, 18.09154, 1.0, 'Söder om Södermalm — omvandlat från industriområde till bostadsdel, känt för miljöprofilen')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
