with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Svenska nöjes- och djurparker', 'I vilken kommun ligger parken?', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('I vilken kommun ligger Kolmårdens djurpark?', '0581', 'Norrköping — Sveriges största djurpark, känd för sina delfiner'),
    ('I vilken kommun ligger High Chaparral?', '0617', 'Gnosjö — Vilda västern-tema i Hillerstorp i Småland')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
