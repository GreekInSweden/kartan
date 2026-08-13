-- ============================================================
-- Kartan — stänger av alla länsklick-rundor (typ='lan').
-- Allt innehåll samlas nu under kommunklick istället.
-- Länsklick-fliken finns kvar i appen (om ni vill använda den
-- igen senare), men har inga aktiva rundor efter detta.
-- ============================================================

update kartan_rundor set is_aktiv = false where typ = 'lan';
