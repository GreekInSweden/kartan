-- ============================================================
-- Kartan — Kommunklick: Allsvenskan 2026, klubbarnas hemkommun
-- Källa: Wikipedia (2026 Allsvenskan), Visit Blekinge, klubbarnas
-- egna sajter. Medvetet urval: bara klubbar där namnet INTE
-- avslöjar orten (skippar Malmö FF, Kalmar FF, Halmstads BK osv).
-- Kör EFTER 005_add_kommun_typ.sql.
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Allsvenskan — hemkommun', 'Från vilken kommun kommer klubben? (namnet avslöjar det inte alltid)', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('Från vilken kommun kommer fotbollslaget AIK?', '0184', 'Solna — Grundat 1891, en av Sveriges mest framgångsrika klubbar — men spelar alltså inte i Stockholms kommun'),
    ('Från vilken kommun kommer fotbollslaget BK Häcken?', '1480', 'Göteborg — Allsvensk klubb från Hisingen'),
    ('Från vilken kommun kommer fotbollslaget GAIS?', '1480', 'Göteborg — Göteborgs Atlet- och Idrottssällskap, en av landets äldsta klubbar'),
    ('Från vilken kommun kommer fotbollslaget IF Elfsborg?', '1490', 'Borås — Namnet kommer från det historiska landskapet Älvsborg'),
    ('Från vilken kommun kommer fotbollslaget IK Sirius?', '0380', 'Uppsala — Uppsala-klubb som chockade allsvenskan säsongen 2026'),
    ('Från vilken kommun kommer fotbollslaget Mjällby AIF?', '1083', 'Sölvesborg — Sveriges mästare 2025 — klubben håller till i fiskeläget Hällevik'),
    ('Från vilken kommun kommer fotbollslaget Örgryte IS?', '1480', 'Göteborg — En av Sveriges äldsta idrottsföreningar, grundad 1887'),
    ('Från vilken kommun kommer fotbollslaget Djurgårdens IF?', '0180', 'Stockholm — Uppkallad efter stadsdelen Djurgården'),
    ('Från vilken kommun kommer fotbollslaget Hammarby IF?', '0180', 'Stockholm — Uppkallad efter stadsdelen Hammarby på Söder'),
    ('Från vilken kommun kommer fotbollslaget IF Brommapojkarna?', '0180', 'Stockholm — Från stadsdelen Bromma, en av allsvenskans mindre klubbar')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
