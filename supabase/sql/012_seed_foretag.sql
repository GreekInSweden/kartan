with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Svenska företag — var grundades de?', 'I vilken kommun grundades företaget?', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('I vilken kommun grundades IKEA?', '0765', 'Älmhult — Ingvar Kamprad öppnade sin första butik här 1958'),
    ('I vilken kommun grundades H&M?', '1980', 'Västerås — Erling Persson öppnade damklädesbutiken Hennes 1947'),
    ('I vilken kommun grundades Absolut Vodka?', '1290', 'Kristianstad — Destilleras fortfarande i Åhus, en tätort i kommunen'),
    ('I vilken kommun grundades Tetra Pak?', '1281', 'Lund — Grundat av Ruben Rausing 1951, nära Lunds universitet')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
