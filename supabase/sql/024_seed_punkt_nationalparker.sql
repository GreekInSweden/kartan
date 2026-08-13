-- ============================================================
-- Kartan — Nålgissning: svenska nationalparker
-- Källa: Wikipedia (respektive nationalparks artikel/infobox).
-- Tolerans skalad efter parkens fysiska storlek.
-- Kör EFTER 001_kartan_schema.sql (typ='punkt' behöver ingen
-- extra migrering).
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Svenska nationalparker (nålgissning)', 'Var i landet ligger parken?', 'punkt')
  returning id
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Sarek nationalpark?', 67.283, 17.7, 35, 'Norrbotten — ett av Europas sista riktiga vildmarksområden, ingen markerad led'),
    ('Var ligger Abisko nationalpark?', 68.317, 18.683, 25, 'Kiruna kommun — känd för norrsken och Kungsleden'),
    ('Var ligger Padjelanta nationalpark?', 67.367, 16.8, 35, 'Norrbotten — Sveriges till ytan största nationalpark, del av världsarvet Laponia'),
    ('Var ligger Muddus nationalpark?', 66.9, 20.167, 30, 'Gällivare/Jokkmokks kommun — vidsträckta myrar och urskog, del av Laponia'),
    ('Var ligger Stenshuvud nationalpark?', 55.667, 14.267, 12, 'Simrishamns kommun, Skåne — ett 97 meter högt kustnära berg'),
    ('Var ligger Skuleskogen nationalpark?', 63.117, 18.5, 20, 'Del av världsarvet Höga kusten, Västernorrland'),
    ('Var ligger Tyresta nationalpark?', 59.183, 18.3, 15, 'Bara två mil från centrala Stockholm — urskog och ett tiotal sjöar'),
    ('Var ligger Store Mosse nationalpark?', 57.267, 13.917, 15, 'Småland — Sydsveriges största sammanhängande myrområde'),
    ('Var ligger Gotska Sandön nationalpark?', 58.367, 19.25, 20, 'En obebodd ö i Östersjön, 38 km norr om Fårö'),
    ('Var ligger Fulufjällets nationalpark?', 61.583, 12.667, 20, 'Älvdalens kommun, Dalarna — hem till Njupeskär, Sveriges högsta vattenfall'),
    ('Var ligger Töfsingdalens nationalpark?', 62.167, 12.433, 20, 'Älvdalens kommun, Dalarna — blockrikt dalgångslandskap')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
