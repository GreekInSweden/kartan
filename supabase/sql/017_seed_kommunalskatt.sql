-- ============================================================
-- Kartan — Kommunklick: kommunalskatt, nationellt + per län
-- Källa: SCB via Kolada (Kommunatlas.se), skattesats 2026.
-- Kör EFTER 005_add_kommun_typ.sql.
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Kommunalskatt — Sverige', 'Lägst/högst kommunalskatt i landet', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Vilken kommun i Sverige har lägst kommunalskatt?', '0117', 'Österåker — 28.93 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Sverige har högst kommunalskatt?', '2425', 'Dorotea — 35.65 % (SCB/Kolada 2026)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Lägst kommunalskatt i länet', 'Lägst kommunalskatt per län', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Vilken kommun i Stockholms län har lägst kommunalskatt?', '0117', 'Österåker — 28.93 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Uppsala län har lägst kommunalskatt?', '0330', 'Knivsta — 32.62 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Södermanlands län har lägst kommunalskatt?', '0488', 'Trosa — 32.03 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Östergötlands län har lägst kommunalskatt?', '0580', 'Linköping — 31.75 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Jönköpings län har lägst kommunalskatt?', '0665', 'Vaggeryd — 33.25 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Kronobergs län har lägst kommunalskatt?', '0780', 'Växjö — 32.19 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Kalmar län har lägst kommunalskatt?', '0883', 'Västervik — 33.02 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Blekinge län har lägst kommunalskatt?', '1081', 'Ronneby — 33.68 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Skåne län har lägst kommunalskatt?', '1261', 'Kävlinge — 29.59 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Hallands län har lägst kommunalskatt?', '1383', 'Varberg — 31.73 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Västra Götalands län har lägst kommunalskatt?', '1402', 'Partille — 31.36 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Värmlands län har lägst kommunalskatt?', '1780', 'Karlstad — 33.55 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Örebro län har lägst kommunalskatt?', '1880', 'Örebro — 33.65 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Västmanlands län har lägst kommunalskatt?', '1980', 'Västerås — 31.24 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Dalarnas län har lägst kommunalskatt?', '2031', 'Rättvik — 33.80 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Gävleborgs län har lägst kommunalskatt?', '2184', 'Hudiksvall — 33.12 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Västernorrlands län har lägst kommunalskatt?', '2284', 'Örnsköldsvik — 33.85 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Jämtlands län har lägst kommunalskatt?', '2380', 'Östersund — 33.72 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Västerbottens län har lägst kommunalskatt?', '2482', 'Skellefteå — 34.45 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Norrbottens län har lägst kommunalskatt?', '2581', 'Piteå — 33.59 % (SCB/Kolada 2026)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Högst kommunalskatt i länet', 'Högst kommunalskatt per län', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Vilken kommun i Stockholms län har högst kommunalskatt?', '0181', 'Södertälje — 32.38 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Uppsala län har högst kommunalskatt?', '0319', 'Älvkarleby — 34.40 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Södermanlands län har högst kommunalskatt?', '0428', 'Vingåker — 33.50 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Östergötlands län har högst kommunalskatt?', '0584', 'Vadstena — 34.35 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Jönköpings län har högst kommunalskatt?', '0682', 'Nässjö — 34.30 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Kronobergs län har högst kommunalskatt?', '0763', 'Tingsryd — 34.00 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Kalmar län har högst kommunalskatt?', '0884', 'Vimmerby — 34.22 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Blekinge län har högst kommunalskatt?', '1083', 'Sölvesborg — 33.86 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Skåne län har högst kommunalskatt?', '1273', 'Osby — 33.99 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Hallands län har högst kommunalskatt?', '1315', 'Hylte — 33.85 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Västra Götalands län har högst kommunalskatt?', '1430', 'Munkedal — 34.86 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Värmlands län har högst kommunalskatt?', '1761', 'Hammarö — 35.05 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Örebro län har högst kommunalskatt?', '1862', 'Degerfors — 35.30 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Västmanlands län har högst kommunalskatt?', '1962', 'Norberg — 33.54 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Dalarnas län har högst kommunalskatt?', '2039', 'Älvdalen — 34.77 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Gävleborgs län har högst kommunalskatt?', '2104', 'Hofors — 34.37 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Västernorrlands län har högst kommunalskatt?', '2283', 'Sollefteå — 34.68 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Jämtlands län har högst kommunalskatt?', '2305', 'Bräcke — 35.09 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Västerbottens län har högst kommunalskatt?', '2425', 'Dorotea — 35.65 % (SCB/Kolada 2026)'),
    ('Vilken kommun i Norrbottens län har högst kommunalskatt?', '2506', 'Arjeplog — 34.84 % (SCB/Kolada 2026)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
