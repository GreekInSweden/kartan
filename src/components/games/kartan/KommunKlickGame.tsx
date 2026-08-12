"use client";

import { useState } from "react";
import { KartanSvgMap } from "./KartanSvgMap";
import { useKartanRound } from "@/hooks/useKartanRound";
import { useSubmitKartanGuess } from "@/hooks/useSubmitKartanGuess";
import { useKartanStats } from "@/hooks/useKartanStats";
import type { KartanGuessResultat } from "@/types/kartan";
import styles from "./kartan.module.css";

interface KommunKlickGameProps {
  spelareId: string;
}

function friendlyError(message: string): string {
  if (message.includes("redan gissat")) {
    return "Du har redan gissat på den här rundan.";
  }
  return message;
}

/** Spelmoment 3 — spelaren klickar den kommun som svarar på frågan (290 möjliga svar). */
export function KommunKlickGame({ spelareId }: KommunKlickGameProps) {
  const [roundKey, setRoundKey] = useState(0);
  const [statsKey, setStatsKey] = useState(0);
  const { runda, loading, error } = useKartanRound("kommun", roundKey);
  const { submitGuess, submitting, error: guessError } = useSubmitKartanGuess(spelareId);
  const { stats } = useKartanStats(spelareId, "kommun", statsKey);

  const [guessId, setGuessId] = useState<string | null>(null);
  const [guessName, setGuessName] = useState<string | null>(null);
  const [resultat, setResultat] = useState<KartanGuessResultat | null>(null);

  const statsCard = stats && (
    <div className={styles.statsCard}>
      <p className={styles.statsTitle}>Din statistik</p>
      <div className={styles.statsRow}>
        <span>Rundor spelade</span>
        <span className={styles.statsRowValue}>{stats.spelade}</span>
      </div>
      <div className={styles.statsRow}>
        <span>Snittpoäng</span>
        <span className={styles.statsRowValue}>{stats.snittPoang}</span>
      </div>
      <div className={styles.statsRow}>
        <span>Bästa resultat</span>
        <span className={styles.statsRowValue}>{stats.bastaPoang}</span>
      </div>
    </div>
  );

  const quotaCard = stats && stats.totaltAntal > 0 && (
    <div className={styles.quotaCard}>
      {stats.kvarAntal > 0 ? (
        <>
          <p className={styles.quotaLabel}>
            {stats.kvarAntal} av {stats.totaltAntal} rundor kvar att spela
          </p>
          <div className={styles.quotaBarTrack}>
            <div
              className={styles.quotaBarFill}
              style={{ width: `${(stats.spelade / stats.totaltAntal) * 100}%` }}
            />
          </div>
        </>
      ) : (
        <p className={styles.quotaDone}>Du har spelat alla {stats.totaltAntal} rundor!</p>
      )}
    </div>
  );

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
    if (!guessId || !runda) return;
    const res = await submitGuess({ typ: "kommun", rundaId: runda.id, platsId: guessId });
    if (res) {
      setResultat(res);
      setStatsKey((k) => k + 1);
    }
  }

  function handleNyRunda() {
    setGuessId(null);
    setGuessName(null);
    setResultat(null);
    setRoundKey((k) => k + 1);
  }

  const revealed = resultat !== null;

  return (
    <div className={styles.gameLayout}>
      <div className={styles.sidebar}>
        {statsCard}

        <p className={styles.category}>{runda.titel}</p>

        {!revealed ? (
          <>
            <button
              className={styles.primaryButton}
              disabled={!guessId || submitting}
              onClick={handleVisaSvar}
            >
              {guessId ? `Visa svar (gissning: ${guessName})` : "Välj en kommun"}
            </button>
            {guessError && <p className={styles.errorNote}>{friendlyError(guessError)}</p>}
          </>
        ) : (
          <div className={styles.resultCard}>
            <p className={styles.resultLabel}>Rätt svar</p>
            <p className={styles.resultValue}>{resultat?.visadVarde}</p>
            <p
              className={
                resultat?.korrekt
                  ? `${styles.resultDetail} ${styles.resultDetailGood}`
                  : styles.resultDetail
              }
            >
              {resultat?.korrekt ? "Helt rätt!" : "Inte riktigt — men nära nog?"}
            </p>
            <p className={styles.resultDetail}>Poäng: {resultat?.poang}</p>
            <button className={styles.secondaryButton} onClick={handleNyRunda}>
              Ny runda
            </button>
          </div>
        )}

        {quotaCard}
      </div>

      <div className={styles.mapArea}>
        <KartanSvgMap
          geoSource="sweden-municipalities"
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
      </div>
    </div>
  );
}
