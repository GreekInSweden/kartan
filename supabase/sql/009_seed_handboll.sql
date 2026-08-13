-- ============================================================
-- Kartan — Kommunklick: Handbollsligan, klubbarnas hemkommun
-- Källa: Wikipedia (klubbsidor), svenskhandboll.se, klubbarnas
-- egna webbplatser. Samma princip som Allsvenskan-filen: bara
-- klubbar där namnet inte gör svaret uppenbart.
-- Kör EFTER 005_add_kommun_typ.sql.
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Handbollsligan — hemkommun', 'Från vilken kommun kommer klubben?', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Från vilken kommun kommer handbollslaget IK Sävehof?', '1402', 'Partille — 17 SM-guld på damsidan — men klubben spelar inte i Göteborg, trots att många tror det'),
    ('Från vilken kommun kommer handbollslaget Redbergslids IK?', '1480', 'Göteborg — En av Sveriges mest framgångsrika handbollsklubbar genom tiderna'),
    ('Från vilken kommun kommer handbollslaget Lugi HF?', '1281', 'Lund — Namnet står för Lunds Universitets Gymnastik- och Idrottsförening'),
    ('Från vilken kommun kommer handbollslaget BK Heid?', '1480', 'Göteborg — Håller till i Västra Frölunda, i Heidhallen'),
    ('Från vilken kommun kommer handbollslaget Önnereds HK?', '1480', 'Göteborg — Uppkallad efter stadsdelen Önnered')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
