with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Bandy — hemkommun', 'Var kommer klubben ifrån?', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Från vilken kommun kommer bandyklubben Edsbyns IF?', '2121', 'Ovanåker — 13-faldiga svenska mästare, spelar i Edsbyn i södra Hälsingland')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
