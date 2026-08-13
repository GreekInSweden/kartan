-- ============================================================
-- Kartan — Kommunklick: sista omgången mot 250
-- Källa: Wikipedia, FN. Björn Borg uteslöts medvetet — han
-- FÖDDES i Stockholm (växte bara upp i Södertälje), och Stockholm
-- är för uppenbart för att vara en bra fråga.
-- Kör EFTER 005_add_kommun_typ.sql.
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Sista omgången mot 250', 'Blandade fakta', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('I vilken kommun föddes Dag Hammarskjöld, FN:s andre generalsekreterare?', '0680', 'Jönköping — föddes 1905, tilldelades Nobels fredspris postumt 1961'),
    ('I vilken kommun grundades lastbilstillverkaren Scania?', '0181', 'Södertälje — huvudkontor och fabrik sedan starten')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
