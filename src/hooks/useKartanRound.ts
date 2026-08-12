"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import type { KartanRunda, KartanSpeltyp } from "@/types/kartan";

interface UseKartanRoundResult {
  runda: KartanRunda | null;
  loading: boolean;
  error: string | null;
}

/**
 * Hämtar en SLUMPAD aktiv runda av given typ ("lan" eller "punkt"), oavsett
 * vilken kategori den tillhör. Detta gör att alla kategorier ni skapar via
 * admin-gränssnittet faktiskt roterar i spelet, istället för att bara en
 * hårdkodad kategori någonsin visas.
 *
 * OBS: rätt svar (rattPlatsId / rattLat / rattLon) skickas ALDRIG till
 * klienten här — precis som KanDuAlla:s /api/game/guess-mönster valideras
 * gissningen och avslöjas facit endast av submit_kartan_guess-RPC:en efter
 * att spelaren gissat.
 *
 * `refreshKey` — ändra detta värde (t.ex. en räknare som ökas) för att
 * tvinga fram en NY slumpad runda, t.ex. när spelaren klickar "Ny runda".
 */
export function useKartanRound(typ: KartanSpeltyp, refreshKey: number = 0): UseKartanRoundResult {
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
        .select("id, kategori_id, titel, typ")
        .eq("typ", typ)
        .eq("is_aktiv", true);

      if (cancelled) return;

      if (dbError) {
        setError(dbError.message);
        setLoading(false);
        return;
      }

      if (!data || data.length === 0) {
        setRunda(null);
        setLoading(false);
        return;
      }

      const vald = data[Math.floor(Math.random() * data.length)];

      setRunda({
        id: vald.id,
        kategoriId: vald.kategori_id,
        titel: vald.titel,
        typ: vald.typ,
        visadVarde: "",
      });
      setLoading(false);
    }

    fetchRound();
    return () => {
      cancelled = true;
    };
  }, [typ, refreshKey]);

  return { runda, loading, error };
}
