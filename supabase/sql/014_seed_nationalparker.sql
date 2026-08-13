with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Svenska nationalparker', 'I vilken kommun ligger huvuddelen av nationalparken?', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('I vilken kommun ligger Abisko nationalpark?', '2584', 'Kiruna — Känd för norrsken och Kungsleden'),
    ('I vilken kommun ligger Sarek nationalpark?', '2510', 'Jokkmokk — Ett av Europas sista riktiga vildmarksområden'),
    ('I vilken kommun ligger Fulufjällets nationalpark?', '2039', 'Älvdalen — Hem till Njupeskär, Sveriges högsta vattenfall'),
    ('I vilken kommun ligger Töfsingdalens nationalpark?', '2361', 'Härjedalen — Karg terräng med stenblock från istiden')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
