-- ============================================================
-- Kartan — Kommunklick: SHL, klubbarnas hemkommun
-- Källa: Wikipedia, klubbarnas egna webbplatser, dagenshockey.se.
-- Samma princip: bara klubbar där namnet inte avslöjar orten.
-- Kör EFTER 005_add_kommun_typ.sql.
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('SHL — hemkommun', 'Från vilken kommun kommer ishockeyklubben?', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Från vilken kommun kommer ishockeylaget Rögle BK?', '1292', 'Ängelholm — Grundad som bandyklubb 1932, vann Champions Hockey League 2022'),
    ('Från vilken kommun kommer ishockeylaget Frölunda HC?', '1480', 'Göteborg — Uppkallad efter stadsdelen Frölunda, flerfaldiga svenska mästare'),
    ('Från vilken kommun kommer ishockeylaget Brynäs IF?', '2180', 'Gävle — Uppkallad efter stadsdelen Brynäs, en av SHL:s mest framgångsrika klubbar'),
    ('Från vilken kommun kommer ishockeylaget MoDo Hockey?', '2284', 'Örnsköldsvik — Namnet står för Mo och Domsjö, det gamla industribolaget')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
