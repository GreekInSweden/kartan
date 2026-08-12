# Kartan

Ett komplett, körbart Next.js-projekt. Klona/pusha till GitHub, kör `npm install`,
kör SQL-filerna i `supabase/sql/` i din Supabase-databas, och kör `npm run dev`.

`.env.local` finns redan ifylld med din Supabase-URL och anon-nyckel — den
committas ALDRIG till GitHub (skyddad av `.gitignore`). Om du klonar ner detta
på en annan dator måste du skapa `.env.local` där igen manuellt.

---

# Kartan — nästa steg efter prototypen

Det här är riktig kod i er Next.js/TypeScript-struktur, med **riktig svensk geodata**
(inte schematisk som i klick-prototypen). Redo att kopieras in i era projekt-repo.

## Vad är med

```
public/data/kartan/
  sweden-regions.geojson         21 län, förenklade (~23 KB)
  sweden-municipalities.geojson  290 kommuner, förenklade (~300 KB)
  region-centroids.json          {id: {namn, lat, lon}} för alla län
  municipality-centroids.json    samma för alla kommuner (inkl. lan_code)

src/types/kartan.ts              Delade TS-typer
src/lib/kartan/geo.ts            d3-geo-projektion + haversine-avstånd + poängmodell
src/components/games/kartan/
  KartanSvgMap.tsx                Kartrenderaren (delas av båda spelmomenten)
  LanKlickGame.tsx                 Spelmoment 1: klicka rätt län
  NalgissningGame.tsx              Spelmoment 2: droppa en nål, poäng efter avstånd
  kartan.module.css                Zoom+glow-avslöjandet, samma känsla som prototypen
src/hooks/
  useKartanRound.ts                Hämtar aktiv runda (INTE facit)
  useSubmitKartanGuess.ts          Anropar RPC:en, får facit + poäng tillbaka
src/app/spel/kartan/page.tsx     Exempel-sida som kopplar ihop allt

supabase/sql/
  001_kartan_schema.sql          Tabeller, RLS, submit_kartan_guess-RPC
  002_seed_lan.sql               INSERT för alla 21 län (riktiga koordinater)
  003_seed_kommuner.sql          INSERT för alla 290 kommuner (för framtida kommun-läge)
```

## Var kommer geodatan ifrån?

`okfse/sweden-geojson` (MIT, öppen data ursprungligen från Valmyndigheten /
SCB-liknande källor). Jag har kört den genom `shapely`:
- **simplify()** för att hålla filstorleken nere (23 KB / 300 KB istället för flera MB)
- **representative_point()** istället för geometrisk centroid, så att punkten
  garanterat hamnar inuti länet/kommunen (viktigt för zoom-targeting vid avslöjande)

Förenklingen är inte topologimedveten — gränser mellan grannregioner kan ha
mikroskopiska glapp. Fullt okej för visualisering, men inte för areaberäkningar.

## Säkerhetsmönstret — samma som Spelkväll/KanDuAlla

Precis som `record_score`-RPC:en i Spelkväll och `/api/game/guess` i KanDuAlla:
**facit skickas aldrig till klienten förrän efter en godkänd gissning.**

1. `useKartanRound` hämtar bara frågan (`titel`), inte svaret
2. Spelaren gissar → `useSubmitKartanGuess` anropar `submit_kartan_guess`-RPC:en
3. RPC:en (SECURITY DEFINER) validerar, beräknar poäng server-side, sparar
   gissningen (en per spelare/runda, enforcerat av en UNIQUE-constraint) och
   returnerar facit + poäng i samma svar
4. `KartanSvgMap` använder det returnerade facit för zoom+glow-avslöjandet

## Vad som INTE är klart än

- **Autentisering/spelare-koppling**: `page.tsx` har en hårdkodad `DEMO_SPELARE_ID`.
  Byt ut mot er befintliga spelar-/session-context.
- **Admin-gränssnitt** för att skapa kategorier och rundor (`kartan_kategorier`,
  `kartan_rundor`) — just nu måste dessa läggas in manuellt eller via ett separat
  script. Säg till om ni vill ha det som nästa byggsteg.
- **npm-paket som behöver installeras**: `d3-geo` och `@types/geojson`
  (`npm install d3-geo @types/geojson`)
- **`@/lib/supabase/client`**: hooken förutsätter att ni redan har er vanliga
  Supabase-klient-helper på den sökvägen (samma som i Spelkväll/KanDuAlla). Justera
  importvägen om er struktur skiljer sig.
- **Kommun-nivå-läge**: `municipality-centroids.json` och seed-filen för 290
  kommuner finns redan förberedda, men `LanKlickGame` pekar bara på
  `sweden-regions.geojson` idag. Byt `geoSource` till `"sweden-municipalities"`
  när ni vill gå ner på kommunnivå.

## Att testa lokalt

1. Kör SQL-filerna i ordning i Supabase (001 → 002 → 003)
2. Lägg in minst en rad i `kartan_kategorier` och en i `kartan_rundor` för
   respektive typ (`lan` / `punkt`), peka på ett `ratt_plats_id` eller
   `ratt_lat`/`ratt_lon` från seed-datan
3. Klistra in de riktiga `kategori_id`:na i `page.tsx`
4. `npm install d3-geo @types/geojson` och starta dev-servern
