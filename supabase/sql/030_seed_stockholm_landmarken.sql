-- ============================================================
-- Kartan — Temapaket: Stockholm, landmärken (nålgissning)
-- Källa: Wikipedia (respektive landmärkes infobox-koordinater).
-- OBS tight tolerans (0.5-0.8 km) — kalibrerad för stadsnära
-- precision, inte landsomfattande. Kräver 029_skalad_poang_narbild.sql
-- (annars blir poängkurvan för snäll för dessa avstånd).
-- Kör EFTER 001-029.
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Stockholm — landmärken', 'Kända platser i Stockholm, exakt koordinat', 'punkt')
  returning id
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Skansen?', 59.32611, 18.10361, 0.8, 'Djurgården — världens äldsta friluftsmuseum, öppnat 1891'),
    ('Var ligger Stockholms stadshus?', 59.3275, 18.055, 0.6, 'Vid Riddarfjärden — här hålls Nobelfestens middag varje år'),
    ('Var ligger Vasamuseet?', 59.3281, 18.0914, 0.7, 'Djurgården — hem till regalskeppet Vasa som sjönk på jungfruresan 1628'),
    ('Var ligger Sergels torg?', 59.3328, 18.06531, 0.5, 'Stockholms mest kända torg, med den karakteristiska glasobelisken'),
    ('Var ligger Avicii Arena (f.d. Globen)?', 59.29361, 18.08333, 0.8, 'Johanneshov — världens största klotformade byggnad när den invigdes 1989'),
    ('Var ligger Kungliga slottet?', 59.32694, 18.07167, 0.5, 'Gamla stan — ett av Europas största slott, över 600 rum'),
    ('Var ligger Kungliga Operan?', 59.32972, 18.07056, 0.5, 'Gustav Adolfs torg — där Gustav III sköts 1792')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
