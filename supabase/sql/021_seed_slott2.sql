with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Svenska slott, omgång 2', 'I vilken kommun ligger slottet?', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('I vilken kommun ligger Bosjökloster?', '1267', 'Höör — Medeltida kloster vid Ringsjön i Skåne')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
