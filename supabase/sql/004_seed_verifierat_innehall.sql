-- ============================================================
-- Kartan — verifierat startinnehåll
-- Källor: SCB (befolkning/yta), Länsstyrelsen Norrbotten, Wikipedia
-- (Sveriges ytterpunkter), verifierade GPS-koordinater.
-- Kör i Supabase SQL Editor EFTER 001/002/003.
-- ============================================================

-- ---------- LÄNSKLICK-rundor (typ='lan') ----------

with k1 as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Störst till ytan', 'Geografisk storlek per län', 'lan')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilket län är Sveriges till ytan största?', 'lan', '25',
  'Norrbottens län — cirka 97 239 km², en fjärdedel av Sveriges yta', true
from k1;

with k2 as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Minst till ytan', 'Geografisk storlek per län', 'lan')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilket län är Sveriges till ytan minsta?', 'lan', '10',
  'Blekinge län — cirka 2 900 km²', true
from k2;

with k3 as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Flest invånare', 'Befolkning per län', 'lan')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilket län har flest invånare?', 'lan', '1',
  'Stockholms län — cirka 2 486 000 invånare, ungefär 23 % av Sveriges befolkning (SCB, dec 2025)', true
from k3;

with k4 as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Två grannländer', 'Geografiskt unika län', 'lan')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilket är det enda svenska län som gränsar till två andra länder?', 'lan', '25',
  'Norrbottens län — gränsar till både Norge och Finland', true
from k4;

with k5 as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Sveriges högsta berg', 'Naturgeografi per län', 'lan')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'I vilket län ligger Kebnekaise, Sveriges högsta berg?', 'lan', '25',
  'Norrbottens län — Kebnekaise är cirka 2 097 meter över havet', true
from k5;

with k6 as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Sydligast', 'Geografiskt läge per län', 'lan')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilket län ligger längst söderut i Sverige?', 'lan', '12',
  'Skåne län', true
from k6;

with k7 as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Ö-länet', 'Geografiskt unika län', 'lan')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select id, 'Vilket län består i sin helhet av en ö i Östersjön?', 'lan', '9',
  'Gotlands län', true
from k7;

-- ---------- NÅLGISSNINGS-rundor (typ='punkt') ----------

with p1 as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Sveriges ytterpunkter', 'Geografiska ytterlighetspunkter', 'punkt')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select id, 'Var ligger Treriksröset, Sveriges nordligaste punkt?', 'punkt',
  69.0600, 20.5486, 25,
  'Treriksröset, Kiruna kommun — där Sverige, Norge och Finland möts', true
from p1;

with p2 as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Sveriges sydspets', 'Geografiska ytterlighetspunkter', 'punkt')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select id, 'Var ligger Smygehuk, Sveriges sydligaste punkt?', 'punkt',
  55.3369, 13.3594, 15,
  'Smygehuk, Trelleborgs kommun, Skåne', true
from p2;

with p3 as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Toppen av Sverige', 'Naturgeografiska landmärken', 'punkt')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select id, 'Var ligger Kebnekaise, Sveriges högsta berg?', 'punkt',
  67.9020, 18.5710, 25,
  'Kebnekaise, Norrbottens län — cirka 2 097 meter över havet', true
from p3;

with p4 as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Malmfälten', 'Städer och orter', 'punkt')
  returning id
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select id, 'Var ligger Kiruna?', 'punkt',
  67.8558, 20.2253, 30,
  'Kiruna, Norrbotten', true
from p4;
