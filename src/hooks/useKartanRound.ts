"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client"; // återanvänder ert befintliga Supabase-klient-helper
import type { KartanRunda } from "@/types/kartan";

interface UseKartanRoundResult {
  runda: KartanRunda | null;
  loading: boolean;
  error: string | null;
}

/**
 * Hämtar den aktiva rundan för en given kategori. OBS: rätt svar (rattPlatsId / rattLat / rattLon)
 * skickas ALDRIG till klienten här — precis som KanDuAlla:s /api/game/guess-mönster valideras
 * gissningen och avslöjas facit endast av submit_kartan_guess-RPC:en efter att spelaren gissat.
 */
export function useKartanRound(kategoriId: string): UseKartanRoundResult {
  const [runda, setRunda] = useState<KartanRunda | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const supabase = createClient();

    async function fetchRound() {
      setLoading(true);
      setError(null);

      const { data, error: dbError } = await supabase
        .from("kartan_rundor")
        .select(
          `
          id,
          kategori_id,
          titel,
          typ,
          kartan_kategorier ( namn, beskrivning )
        `
        )
        .eq("kategori_id", kategoriId)
        .eq("is_aktiv", true)
        .order("skapad_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (cancelled) return;

      if (dbError) {
        setError(dbError.message);
        setLoading(false);
        return;
      }

      if (!data) {
        setRunda(null);
        setLoading(false);
        return;
      }

      setRunda({
        id: data.id,
        kategoriId: data.kategori_id,
        titel: data.titel,
        typ: data.typ,
        visadVarde: "", // fylls i efter gissning, se useSubmitKartanGuess
      });
      setLoading(false);
    }

    fetchRound();
    return () => {
      cancelled = true;
    };
  }, [kategoriId]);

  return { runda, loading, error };
}
