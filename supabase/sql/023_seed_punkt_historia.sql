-- ============================================================
-- Kartan — Nålgissning: historiska platser och landmärken
-- Källa: Wikipedia, Kramfors kommun, Vasaloppet.se, Visit Ystad.
-- Kör EFTER 001_kartan_schema.sql (kräver ingen kommun-migrering,
-- typ='punkt' fanns redan från start).
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Historiska platser och landmärken', 'Var i Sverige hände det, eller var ligger det?', 'punkt')
  returning id
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Ale stenar, Sveriges största skeppssättning?', 55.3825, 14.0547, 15, 'Ales stenar, Kåseberga, Ystads kommun — 59 stenblock, cirka 1400 år gamla'),
    ('Var startar Vasaloppet?', 61.1162, 13.2952, 20, 'Sälen — loppet går 90 km till Mora, i Gustav Vasas spår från 1520-talet'),
    ('Var går Vasaloppets mål?', 61.0043, 14.542, 15, 'Mora — målportalen har tagit emot löpare sedan 1922'),
    ('Var ägde Ådalen 31 rum, då militär sköt mot demonstrerande arbetare?', 62.9, 17.75, 25, 'Lunde, Kramfors kommun — fem personer dödades den 14 maj 1931')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
