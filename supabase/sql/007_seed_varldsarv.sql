-- ============================================================
-- Kartan — Kommunklick: Sveriges världsarv (UNESCO)
-- Källor: Svenska Unescorådet, Riksantikvarieämbetet, Wikipedia.
-- Medvetet uteslutet: världsarv som sträcker sig över flera
-- kommuner utan ett entydigt facit (Höga kusten, Laponia,
-- Hälsingegårdarna, Struves meridianbåge).
-- Kör EFTER 005_add_kommun_typ.sql.
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Sveriges världsarv', 'I vilken kommun ligger varje UNESCO-världsarv?', 'kommun')
  returning id
),
data(titel, ratt_plats_id, visad_varde) as (
  values
    ('I vilken kommun ligger världsarvet Drottningholms slottsområde?', '0125', 'Ekerö — Sveriges första världsarv (1991) — ett kungligt slott från 1700-talet (världsarv sedan 1991)'),
    ('I vilken kommun ligger världsarvet Birka och Hovgården?', '0125', 'Ekerö — Vikingatida handelsplats och kungsgård i Mälaren (världsarv sedan 1993)'),
    ('I vilken kommun ligger världsarvet Engelsbergs bruk?', '1982', 'Fagersta — Ett av Europas bäst bevarade järnbruk från 1600–1800-talet (världsarv sedan 1993)'),
    ('I vilken kommun ligger världsarvet Hällristningsområdet i Tanum?', '1435', 'Tanum — Bronsålderns hällristningar, ett av världens största områden (världsarv sedan 1994)'),
    ('I vilken kommun ligger världsarvet Skogskyrkogården?', '0180', 'Stockholm — Gunnar Asplunds och Sigurd Lewerentz berömda kyrkogårdsarkitektur (världsarv sedan 1994)'),
    ('I vilken kommun ligger världsarvet Hansestaden Visby?', '0980', 'Gotland — Medeltida ringmur och hansestad (världsarv sedan 1995)'),
    ('I vilken kommun ligger världsarvet Gammelstads kyrkstad?', '2580', 'Luleå — 408 bevarade kyrkstugor från 1600-talet (världsarv sedan 1996)'),
    ('I vilken kommun ligger världsarvet Örlogsstaden Karlskrona?', '1080', 'Karlskrona — Sveriges enda kvarvarande örlogsstad från 1680-talet (världsarv sedan 1998)'),
    ('I vilken kommun ligger världsarvet Södra Ölands odlingslandskap?', '0840', 'Mörbylånga — Brukat sedan stenåldern, 56 000 hektar (världsarv sedan 2000)'),
    ('I vilken kommun ligger världsarvet Falun och Kopparbergslagen?', '2080', 'Falun — Falu koppargruva och det historiska gruvlandskapet (världsarv sedan 2001)'),
    ('I vilken kommun ligger världsarvet Grimeton radiostation?', '1383', 'Varberg — Fungerande radiostation från 1920-talet, unik teknikhistoria (världsarv sedan 2004)')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_plats_id, visad_varde, is_aktiv)
select k.id, data.titel, 'kommun', data.ratt_plats_id, data.visad_varde, true
from k, data;
