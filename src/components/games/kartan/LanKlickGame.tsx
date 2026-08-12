"use client";

import { useState } from "react";
import { KartanSvgMap } from "./KartanSvgMap";
import { useKartanRound } from "@/hooks/useKartanRound";
import { useSubmitKartanGuess } from "@/hooks/useSubmitKartanGuess";
import type { KartanGuessResultat } from "@/types/kartan";
import styles from "./kartan.module.css";

interface LanKlickGameProps {
  kategoriId: string;
  spelareId: string;
}

/** Spelmoment 1 — spelaren klickar det län som svarar på frågan. */
export function LanKlickGame({ kategoriId, spelareId }: LanKlickGameProps) {
  const { runda, loading, error } = useKartanRound(kategoriId);
  const { submitGuess, submitting } = useSubmitKartanGuess(spelareId);

  const [guessId, setGuessId] = useState<string | null>(null);
  const [guessName, setGuessName] = useState<string | null>(null);
  const [resultat, setResultat] = useState<KartanGuessResultat | null>(null);

  if (loading) return <p>Laddar runda…</p>;
  if (error) return <p>Något gick fel: {error}</p>;
  if (!runda) return <p>Ingen aktiv runda just nu.</p>;

  async function handleVisaSvar() {
    if (!guessId || !runda) return;
    const res = await submitGuess({ typ: "lan", rundaId: runda.id, platsId: guessId });
    if (res) setResultat(res);
  }

  function handleNyRunda() {
    setGuessId(null);
    setGuessName(null);
    setResultat(null);
  }

  const revealed = resultat !== null;

  return (
    <div>
      <p className={styles.category}>{runda.titel}</p>

      <KartanSvgMap
        geoSource="sweden-regions"
        clickMode="region"
        guessRegionId={guessId}
        correctRegionId={resultat?.rattPlatsId ?? null}
        revealed={revealed}
        onRegionClick={(id, name) => {
          if (!revealed) {
            setGuessId(id);
            setGuessName(name);
          }
        }}
      />

      {!revealed ? (
        <button disabled={!guessId || submitting} onClick={handleVisaSvar}>
          {guessId ? `Visa svar (gissning: ${guessName})` : "Välj ett län"}
        </button>
      ) : (
        <div>
          <p>Rätt svar: {resultat?.visadVarde}</p>
          <p>{resultat?.korrekt ? "Helt rätt!" : "Inte riktigt — men nära nog?"}</p>
          <p>Poäng: {resultat?.poang}</p>
          <button onClick={handleNyRunda}>Ny runda</button>
        </div>
      )}
    </div>
  );
}
