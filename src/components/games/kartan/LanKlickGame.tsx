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

  if (loading) return <p style={{ color: "#8b94a3" }}>Laddar runda…</p>;
  if (error) return <p style={{ color: "#e8917a" }}>Något gick fel: {error}</p>;
  if (!runda) return <p style={{ color: "#8b94a3" }}>Ingen aktiv runda just nu.</p>;

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
        <button
          className={styles.primaryButton}
          disabled={!guessId || submitting}
          onClick={handleVisaSvar}
        >
          {guessId ? `Visa svar (gissning: ${guessName})` : "Välj ett län"}
        </button>
      ) : (
        <div className={styles.resultCard}>
          <p className={styles.resultLabel}>Rätt svar</p>
          <p className={styles.resultValue}>{resultat?.visadVarde}</p>
          <p className={resultat?.korrekt ? `${styles.resultDetail} ${styles.resultDetailGood}` : styles.resultDetail}>
            {resultat?.korrekt ? "Helt rätt!" : "Inte riktigt — men nära nog?"}
          </p>
          <p className={styles.resultDetail}>Poäng: {resultat?.poang}</p>
          <button className={styles.secondaryButton} onClick={handleNyRunda}>
            Ny runda
          </button>
        </div>
      )}
    </div>
  );
}
