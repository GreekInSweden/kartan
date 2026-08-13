-- ============================================================
-- Kartan — Kommunklick: de gamla länsfakta, omgjorda till kommun-nivå
-- (samma källor som 004: SCB, Länsstyrelsen Norrbotten, Wikipedia).
-- "Flest invånare" och "gränsar till två länder" är medvetet
-- uteslutna: den förra är redan en egen kommun-kategori i 006,
-- den senare saknar ett entydigt kommun-svar (flera Norrbottens-
-- kommuner gränsar till Norge ELLER Finland, men ingen till båda).
-- Kör EFTER 005_add_kommun_typ.sql.
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Geografiska ytterligheter (kommun)', 'Störst, minst, högst och sydligast — på kommunnivå', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Vilken kommun är Sveriges till ytan största?', '2584', 'Kiruna — 20 551 km² — större än flera europeiska länder, t.ex. Slovakien'),
    ('Vilken kommun är Sveriges till ytan minsta?', '0183', 'Sundbyberg — Bara 8,79 km² — ryms nästan 2 350 gånger i Kiruna kommun'),
    ('I vilken kommun ligger Kebnekaise, Sveriges högsta berg?', '2584', 'Kiruna — Kebnekaise är cirka 2 097 meter över havet'),
    ('Vilken kommun ligger längst söderut i Sverige?', '1287', 'Trelleborg — Smygehuk, Sveriges sydligaste punkt, ligger i kommunen'),
    ('Vilken kommun består i sin helhet av en ö i Östersjön?', '0980', 'Gotland — Sedan 2011 är Gotlands län och Gotlands kommun samma område (Region Gotland)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
