-- ============================================================
-- Kartan — Göteborg och omnejd, omgång 1
-- Källa: Wikipedia (infobox-koordinater).
-- Kör EFTER 041_seed_stockholm_omnejd_12.sql (ny kategori, ingen
-- ny schemaändring behövs).
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Göteborg — landmärken', 'Kända platser i Göteborg och omnejd, exakt koordinat', 'punkt')
  returning id
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Liseberg?', 57.69556, 11.99, 0.5, 'Heden, Göteborg — Nordens största nöjespark, invigd 1923'),
    ('Var ligger Ullevi?', 57.70583, 11.98722, 0.6, 'Göteborgs stora evenemangsarena, byggd för fotbolls-VM 1958 — 43 000 sittplatser, upp till 75 000 på konsert'),
    ('Var ligger Gamla Ullevi?', 57.70623, 11.98014, 0.5, 'Hemmaplan för GAIS, IFK Göteborg och Örgryte IS — inte samma arena som stora Ullevi, trots det snarlika namnet')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
