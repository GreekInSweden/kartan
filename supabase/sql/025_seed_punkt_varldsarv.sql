-- ============================================================
-- Kartan — Nålgissning: Sveriges världsarv, exakta koordinater
-- Källa: Wikipedia (respektive världsarvs infobox/artikel).
-- Kompletterar kommun-versionen av samma världsarv i 007 —
-- olika utmaning (exakt punkt vs. kommun), inte en dubblett.
-- Falu koppargruva: koordinat för Falu tätort/gruvområdet,
-- något bredare tolerans då exakt schaktkoordinat inte hittades.
-- Kör EFTER 001_kartan_schema.sql.
-- ============================================================

with k as (
  insert into kartan_kategorier (namn, beskrivning, typ)
  values ('Sveriges världsarv (nålgissning)', 'Exakt var ligger varje världsarv?', 'punkt')
  returning id
),
data(titel, ratt_lat, ratt_lon, tolerans_km, visad_varde) as (
  values
    ('Var ligger Birka, vikingatidens handelsplats?', 59.336, 17.545, 15, 'Björkö, Ekerö kommun — grundades runt år 750, övergavs cirka 975'),
    ('Var ligger Grimeton radiostation?', 57.114, 12.404, 10, 'Varbergs kommun — världens enda fungerande Alexanderson-alternator'),
    ('Var ligger Visby ringmur?', 57.635, 18.299, 10, 'Gotland — 3,4 km medeltida mur, Skandinaviens bäst bevarade'),
    ('Var ligger Örlogsstaden Karlskrona?', 56.162, 15.587, 15, 'Blekinge — grundad 1680, Sveriges huvudbas för örlogsflottan'),
    ('Var ligger Falu koppargruva?', 60.607, 15.625, 20, 'Falun, Dalarna — under 1600-talet en av Sveriges största arbetsplatser'),
    ('Var ligger hällristningarna i Tanum (Vitlyckehällen)?', 58.688, 11.404, 20, 'Tanums kommun, Bohuslän — bronsålderristningar, bland annat scenen "Brudparet"')
)
insert into kartan_rundor (kategori_id, titel, typ, ratt_lat, ratt_lon, tolerans_km, visad_varde, is_aktiv)
select k.id, data.titel, 'punkt', data.ratt_lat, data.ratt_lon, data.tolerans_km, data.visad_varde, true
from k, data;
