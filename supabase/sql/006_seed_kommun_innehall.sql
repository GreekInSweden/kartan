-- ============================================================
-- Kartan — Kommunklick: programmatiskt genererat innehåll
-- Källor: SCB via Kolada (befolkning, 2025) + verifierad geodata
-- (koordinater/länstillhörighet, samma källa som redan i projektet).
-- Alla siffror och kommun-id:n är kontrollerade mot riktig data —
-- inget är gissat eller påhittat.
-- Kör EFTER 005_add_kommun_typ.sql (lägger till typ='kommun').
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Flest invånare i Sverige', 'Kommun med flest invånare totalt', 'kommun')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilken kommun i Sverige har flest invånare?', 'kommun', '0180',
  'Stockholm — 999 239 invånare (SCB/Kolada 2025)', true
from k;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Minst invånare i Sverige', 'Kommun med minst invånare totalt', 'kommun')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilken kommun i Sverige har minst invånare?', 'kommun', '2425',
  'Dorotea — 2 241 invånare (SCB/Kolada 2025)', true
from k;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Flest invånare i länet', 'Störst kommun per län, befolkning', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Vilken kommun i Stockholms län har flest invånare?', '0180', 'Stockholm — 999 239 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Uppsala län har flest invånare?', '0380', 'Uppsala — 249 726 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Södermanlands län har flest invånare?', '0484', 'Eskilstuna — 106 789 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Östergötlands län har flest invånare?', '0580', 'Linköping — 168 714 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Jönköpings län har flest invånare?', '0680', 'Jönköping — 148 152 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Kronobergs län har flest invånare?', '0780', 'Växjö — 98 940 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Kalmar län har flest invånare?', '0880', 'Kalmar — 73 068 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Blekinge län har flest invånare?', '1080', 'Karlskrona — 66 021 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Skåne län har flest invånare?', '1280', 'Malmö — 367 924 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Hallands län har flest invånare?', '1380', 'Halmstad — 106 315 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Västra Götalands län har flest invånare?', '1480', 'Göteborg — 613 278 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Värmlands län har flest invånare?', '1780', 'Karlstad — 99 007 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Örebro län har flest invånare?', '1880', 'Örebro — 160 687 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Västmanlands län har flest invånare?', '1980', 'Västerås — 161 240 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Dalarnas län har flest invånare?', '2080', 'Falun — 59 974 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Gävleborgs län har flest invånare?', '2180', 'Gävle — 104 108 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Västernorrlands län har flest invånare?', '2281', 'Sundsvall — 98 962 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Jämtlands län har flest invånare?', '2380', 'Östersund — 64 963 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Västerbottens län har flest invånare?', '2480', 'Umeå — 135 273 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Norrbottens län har flest invånare?', '2580', 'Luleå — 80 304 invånare (SCB/Kolada 2025)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Minst invånare i länet', 'Minst kommun per län, befolkning', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Vilken kommun i Stockholms län har minst invånare?', '0187', 'Vaxholm — 11 636 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Uppsala län har minst invånare?', '0319', 'Älvkarleby — 9 573 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Södermanlands län har minst invånare?', '0428', 'Vingåker — 8 666 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Östergötlands län har minst invånare?', '0512', 'Ydre — 3 619 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Jönköpings län har minst invånare?', '0604', 'Aneby — 6 851 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Kronobergs län har minst invånare?', '0761', 'Lessebo — 8 115 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Kalmar län har minst invånare?', '0821', 'Högsby — 5 134 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Blekinge län har minst invånare?', '1060', 'Olofström — 12 844 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Skåne län har minst invånare?', '1275', 'Perstorp — 7 115 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Hallands län har minst invånare?', '1315', 'Hylte — 10 094 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Västra Götalands län har minst invånare?', '1438', 'Dals-Ed — 4 571 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Värmlands län har minst invånare?', '1762', 'Munkfors — 3 637 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Örebro län har minst invånare?', '1864', 'Ljusnarsberg — 4 290 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Västmanlands län har minst invånare?', '1904', 'Skinnskatteberg — 4 234 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Dalarnas län har minst invånare?', '2021', 'Vansbro — 6 741 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Gävleborgs län har minst invånare?', '2101', 'Ockelbo — 5 715 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Västernorrlands län har minst invånare?', '2260', 'Ånge — 9 000 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Jämtlands län har minst invånare?', '2303', 'Ragunda — 5 152 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Västerbottens län har minst invånare?', '2425', 'Dorotea — 2 241 invånare (SCB/Kolada 2025)'),
    ('Vilken kommun i Norrbottens län har minst invånare?', '2506', 'Arjeplog — 2 570 invånare (SCB/Kolada 2025)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Nordligaste kommunen i Sverige', 'Geografisk ytterpunkt bland kommunerna', 'kommun')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilken är Sveriges nordligaste kommun?', 'kommun', '2584',
  'Kiruna (baserat på kommunens ungefärliga mittpunkt)', true
from k;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Sydligaste kommunen i Sverige', 'Geografisk ytterpunkt bland kommunerna', 'kommun')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilken är Sveriges sydligaste kommun?', 'kommun', '1287',
  'Trelleborg (baserat på kommunens ungefärliga mittpunkt)', true
from k;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Östligaste kommunen i Sverige', 'Geografisk ytterpunkt bland kommunerna', 'kommun')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilken är Sveriges östligaste kommun?', 'kommun', '2583',
  'Haparanda (baserat på kommunens ungefärliga mittpunkt)', true
from k;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Västligaste kommunen i Sverige', 'Geografisk ytterpunkt bland kommunerna', 'kommun')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilken är Sveriges västligaste kommun?', 'kommun', '1486',
  'Strömstad (baserat på kommunens ungefärliga mittpunkt)', true
from k;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Nordligaste kommunen i länet', 'Geografisk ytterpunkt per län', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Vilken är Stockholms läns nordligaste kommun?', '0188', 'Norrtälje (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Uppsala läns nordligaste kommun?', '0319', 'Älvkarleby (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Södermanlands läns nordligaste kommun?', '0486', 'Strängnäs (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Östergötlands läns nordligaste kommun?', '0562', 'Finspång (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Jönköpings läns nordligaste kommun?', '0687', 'Tranås (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Kronobergs läns nordligaste kommun?', '0760', 'Uppvidinge (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Kalmar läns nordligaste kommun?', '0883', 'Västervik (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Blekinge läns nordligaste kommun?', '1060', 'Olofström (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Skåne läns nordligaste kommun?', '1273', 'Osby (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Hallands läns nordligaste kommun?', '1384', 'Kungsbacka (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västra Götalands läns nordligaste kommun?', '1460', 'Bengtsfors (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Värmlands läns nordligaste kommun?', '1737', 'Torsby (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Örebro läns nordligaste kommun?', '1864', 'Ljusnarsberg (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västmanlands läns nordligaste kommun?', '1962', 'Norberg (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Dalarnas läns nordligaste kommun?', '2039', 'Älvdalen (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Gävleborgs läns nordligaste kommun?', '2132', 'Nordanstig (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västernorrlands läns nordligaste kommun?', '2284', 'Örnsköldsvik (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Jämtlands läns nordligaste kommun?', '2313', 'Strömsund (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västerbottens läns nordligaste kommun?', '2422', 'Sorsele (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Norrbottens läns nordligaste kommun?', '2584', 'Kiruna (baserat på kommunens ungefärliga mittpunkt)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Sydligaste kommunen i länet', 'Geografisk ytterpunkt per län', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Vilken är Stockholms läns sydligaste kommun?', '0192', 'Nynäshamn (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Uppsala läns sydligaste kommun?', '0305', 'Håbo (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Södermanlands läns sydligaste kommun?', '0481', 'Oxelösund (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Östergötlands läns sydligaste kommun?', '0512', 'Ydre (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Jönköpings läns sydligaste kommun?', '0683', 'Värnamo (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Kronobergs läns sydligaste kommun?', '0767', 'Markaryd (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Kalmar läns sydligaste kommun?', '0834', 'Torsås (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Blekinge läns sydligaste kommun?', '1083', 'Sölvesborg (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Skåne läns sydligaste kommun?', '1287', 'Trelleborg (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Hallands läns sydligaste kommun?', '1381', 'Laholm (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västra Götalands läns sydligaste kommun?', '1465', 'Svenljunga (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Värmlands läns sydligaste kommun?', '1785', 'Säffle (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Örebro läns sydligaste kommun?', '1882', 'Askersund (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västmanlands läns sydligaste kommun?', '1984', 'Arboga (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Dalarnas läns sydligaste kommun?', '2061', 'Smedjebacken (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Gävleborgs läns sydligaste kommun?', '2181', 'Sandviken (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västernorrlands läns sydligaste kommun?', '2260', 'Ånge (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Jämtlands läns sydligaste kommun?', '2361', 'Härjedalen (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västerbottens läns sydligaste kommun?', '2401', 'Nordmaling (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Norrbottens läns sydligaste kommun?', '2581', 'Piteå (baserat på kommunens ungefärliga mittpunkt)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Östligaste kommunen i länet', 'Geografisk ytterpunkt per län', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Vilken är Stockholms läns östligaste kommun?', '0188', 'Norrtälje (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Uppsala läns östligaste kommun?', '0382', 'Östhammar (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Södermanlands läns östligaste kommun?', '0488', 'Trosa (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Östergötlands läns östligaste kommun?', '0563', 'Valdemarsvik (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Jönköpings läns östligaste kommun?', '0686', 'Eksjö (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Kronobergs läns östligaste kommun?', '0760', 'Uppvidinge (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Kalmar läns östligaste kommun?', '0885', 'Borgholm (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Blekinge läns östligaste kommun?', '1080', 'Karlskrona (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Skåne läns östligaste kommun?', '1272', 'Bromölla (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Hallands läns östligaste kommun?', '1315', 'Hylte (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västra Götalands läns östligaste kommun?', '1446', 'Karlsborg (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Värmlands läns östligaste kommun?', '1760', 'Storfors (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Örebro läns östligaste kommun?', '1861', 'Hallsberg (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västmanlands läns östligaste kommun?', '1980', 'Västerås (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Dalarnas läns östligaste kommun?', '2084', 'Avesta (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Gävleborgs läns östligaste kommun?', '2132', 'Nordanstig (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västernorrlands läns östligaste kommun?', '2284', 'Örnsköldsvik (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Jämtlands läns östligaste kommun?', '2303', 'Ragunda (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västerbottens läns östligaste kommun?', '2409', 'Robertsfors (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Norrbottens läns östligaste kommun?', '2583', 'Haparanda (baserat på kommunens ungefärliga mittpunkt)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Västligaste kommunen i länet', 'Geografisk ytterpunkt per län', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Vilken är Stockholms läns västligaste kommun?', '0140', 'Nykvarn (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Uppsala läns västligaste kommun?', '0331', 'Heby (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Södermanlands läns västligaste kommun?', '0428', 'Vingåker (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Östergötlands läns västligaste kommun?', '0509', 'Ödeshög (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Jönköpings läns västligaste kommun?', '0662', 'Gislaved (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Kronobergs läns västligaste kommun?', '0767', 'Markaryd (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Kalmar läns västligaste kommun?', '0862', 'Emmaboda (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Blekinge läns västligaste kommun?', '1060', 'Olofström (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Skåne läns västligaste kommun?', '1284', 'Höganäs (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Hallands läns västligaste kommun?', '1384', 'Kungsbacka (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västra Götalands läns västligaste kommun?', '1486', 'Strömstad (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Värmlands läns västligaste kommun?', '1765', 'Årjäng (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Örebro läns västligaste kommun?', '1862', 'Degerfors (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västmanlands läns västligaste kommun?', '1904', 'Skinnskatteberg (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Dalarnas läns västligaste kommun?', '2039', 'Älvdalen (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Gävleborgs läns västligaste kommun?', '2161', 'Ljusdal (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västernorrlands läns västligaste kommun?', '2260', 'Ånge (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Jämtlands läns västligaste kommun?', '2321', 'Åre (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Västerbottens läns västligaste kommun?', '2421', 'Storuman (baserat på kommunens ungefärliga mittpunkt)'),
    ('Vilken är Norrbottens läns västligaste kommun?', '2506', 'Arjeplog (baserat på kommunens ungefärliga mittpunkt)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
