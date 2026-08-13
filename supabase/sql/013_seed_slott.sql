with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Svenska slott', 'I vilken kommun ligger slottet?', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('I vilken kommun ligger Gripsholms slott?', '0486', 'Strängnäs — Ligger i Mariefred, känt för sin porträttsamling'),
    ('I vilken kommun ligger Läckö slott?', '1494', 'Lidköping — Vackert beläget på halvön Kållandsö i Vänern'),
    ('I vilken kommun ligger Skokloster slott?', '0305', 'Håbo — Ett av Europas mest välbevarade barockslott'),
    ('I vilken kommun ligger Sofiero slott?', '1283', 'Helsingborg — Kungafamiljens sommarslott, känt för sina rhododendron'),
    ('I vilken kommun ligger Tjolöholms slott?', '1384', 'Kungsbacka — Nyengelsk arkitektur från sekelskiftet 1900')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
