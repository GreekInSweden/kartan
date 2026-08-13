-- ============================================================
-- Kartan — Kommunklick: kända svenskars födelsekommun, omgång 2
-- Källa: Wikipedia, Forum för levande historia.
-- Kör EFTER 005_add_kommun_typ.sql.
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Kända svenskars födelsekommun 2', 'Var föddes de?', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('I vilken kommun föddes Ingmar Bergman?', '0380', 'Uppsala — Regissören föddes 1918, son till en präst'),
    ('I vilken kommun föddes Agnetha Fältskog?', '0680', 'Jönköping — ABBA-medlemmen föddes 1950'),
    ('I vilken kommun föddes Stieg Larsson?', '2482', 'Skellefteå — Millennium-författaren föddes i Skelleftehamn 1954'),
    ('I vilken kommun föddes Raoul Wallenberg?', '0186', 'Lidingö — Föddes i Kappsta 1912, räddade tiotusentals ungerska judar')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
