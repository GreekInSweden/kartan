-- ============================================================
-- Kartan — Kommunklick: Kända svenskars födelsekommun
-- Källa: allmänt känd biografisk fakta (Wikipedia m.fl.).
-- Kör EFTER 005_add_kommun_typ.sql.
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Kända svenskars födelsekommun', 'Var föddes eller växte de upp?', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('I vilken kommun föddes Astrid Lindgren?', '0884', 'Vimmerby — Föddes på gården Näs 1907 — samma trakt som inspirerade Bullerbyn'),
    ('I vilken kommun föddes Selma Lagerlöf?', '1766', 'Sunne — Växte upp på herrgården Mårbacka i Värmland'),
    ('I vilken kommun föddes Carl von Linné?', '0765', 'Älmhult — Föddes i Råshult i Småland 1707')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
