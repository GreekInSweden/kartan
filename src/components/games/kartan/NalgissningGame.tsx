"use client";

import { useState } from "react";
import { KartanSvgMap } from "./KartanSvgMap";
import { useKartanRound } from "@/hooks/useKartanRound";
import { useSubmitKartanGuess } from "@/hooks/useSubmitKartanGuess";
import type { KartanGuessResultat } from "@/types/kartan";
import styles from "./kartan.module.css";

interface NalgissningGameProps {
  spelareId: string;
}

function friendlyError(message: string): string {
  if (message.includes("redan gissat")) {
    return "Du har redan gissat på den här rundan.";
  }
  return message;
}

/** Spelmoment 2 — spelaren droppar en nål var som helst på kartan. Poäng baseras på avstånd. */
export function NalgissningGame({ spelareId }: NalgissningGameProps) {
  const [roundKey, setRoundKey] = useState(0);
  const { runda, loading, error } = useKartanRound("punkt", roundKey);
  const { submitGuess, submitting, error: guessError } = useSubmitKartanGuess(spelareId);

  const [guessPoint, setGuessPoint] = useState<{ lat: number; lon: number } | null>(null);
  const [resultat, setResultat] = useState<KartanGuessResultat | null>(null);

  if (loading) return <p style={{ color: "#8b94a3" }}>Laddar runda…</p>;
  if (error) return <p style={{ color: "#e8917a" }}>Något gick fel: {error}</p>;
  if (!runda)
    return (
      <p style={{ color: "#8b94a3" }}>
        Ingen aktiv runda just nu. Skapa en i{" "}
        <a href="/admin/kartan" style={{ color: "#e8b84b" }}>
          admin-gränssnittet
        </a>
        .
      </p>
    );

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
    setRoundKey((k) => k + 1);
  }

  const revealed = resultat !== null;
  const correctPoint =
    resultat?.rattLat != null && resultat?.rattLon != null
      ? { lat: resultat.rattLat, lon: resultat.rattLon }
      : null;

  return (
    <div className={styles.gameLayout}>
      <div className={styles.sidebar}>
        <p className={styles.category}>{runda.titel}</p>

        {!revealed ? (
          <>
            <button
              className={styles.primaryButton}
              disabled={!guessPoint || submitting}
              onClick={handleVisaSvar}
            >
              {guessPoint ? "Visa svar" : "Placera en nål"}
            </button>
            {guessError && <p className={styles.errorNote}>{friendlyError(guessError)}</p>}
          </>
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

      <div className={styles.mapArea}>
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
      </div>
    </div>
  );
}
