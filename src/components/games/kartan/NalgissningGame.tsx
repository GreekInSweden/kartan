"use client";

import { useState } from "react";
import { KartanSvgMap } from "./KartanSvgMap";
import { useKartanRound } from "@/hooks/useKartanRound";
import { useSubmitKartanGuess } from "@/hooks/useSubmitKartanGuess";
import type { KartanGuessResultat } from "@/types/kartan";
import styles from "./kartan.module.css";

interface NalgissningGameProps {
  kategoriId: string;
  spelareId: string;
}

/** Spelmoment 2 — spelaren droppar en nål var som helst på kartan. Poäng baseras på avstånd. */
export function NalgissningGame({ kategoriId, spelareId }: NalgissningGameProps) {
  const { runda, loading, error } = useKartanRound(kategoriId);
  const { submitGuess, submitting } = useSubmitKartanGuess(spelareId);

  const [guessPoint, setGuessPoint] = useState<{ lat: number; lon: number } | null>(null);
  const [resultat, setResultat] = useState<KartanGuessResultat | null>(null);

  if (loading) return <p style={{ color: "#8b94a3" }}>Laddar runda…</p>;
  if (error) return <p style={{ color: "#e8917a" }}>Något gick fel: {error}</p>;
  if (!runda) return <p style={{ color: "#8b94a3" }}>Ingen aktiv runda just nu.</p>;

  async function handleVisaSvar() {
    if (!guessPoint || !runda) return;
    const res = await submitGuess({
      typ: "punkt",
      rundaId: runda.id,
      lat: guessPoint.lat,
      lon: guessPoint.lon,
    });
    if (res) setResultat(res);
  }

  function handleNyRunda() {
    setGuessPoint(null);
    setResultat(null);
  }

  const revealed = resultat !== null;
  const correctPoint =
    resultat?.rattLat != null && resultat?.rattLon != null
      ? { lat: resultat.rattLat, lon: resultat.rattLon }
      : null;

  return (
    <div>
      <p className={styles.category}>{runda.titel}</p>

      <KartanSvgMap
        geoSource="sweden-regions"
        clickMode="point"
        guessPoint={guessPoint}
        correctPoint={correctPoint}
        revealed={revealed}
        onMapClick={(lat, lon) => {
          if (!revealed) setGuessPoint({ lat, lon });
        }}
      />

      {!revealed ? (
        <button
          className={styles.primaryButton}
          disabled={!guessPoint || submitting}
          onClick={handleVisaSvar}
        >
          {guessPoint ? "Visa svar" : "Placera en nål"}
        </button>
      ) : (
        <div className={styles.resultCard}>
          <p className={styles.resultLabel}>Rätt svar</p>
          <p className={styles.resultValue}>{resultat?.visadVarde}</p>
          <p className={`${styles.resultDetail} ${styles.resultDetailGood}`}>
            Din gissning låg {Math.round(resultat?.avstandKm ?? 0)} km från rätt plats
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
