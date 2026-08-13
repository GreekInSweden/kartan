"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import type { KartanPaketSummering, KartanPaketFraga } from "@/types/kartan";

/** Hämtar alla publicerade paket — det spelaren väljer bland. */
export function usePubliceradePaket(): { paket: KartanPaketSummering[]; loading: boolean } {
  const [paket, setPaket] = useState<KartanPaketSummering[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    const supabase = createClient();

    supabase
      .from("kartan_paket")
      .select("id, namn")
      .eq("status", "publicerad")
      .order("skapad_at", { ascending: false })
      .then(({ data }) => {
        if (!cancelled) {
          setPaket(data ?? []);
          setLoading(false);
        }
      });

    return () => {
      cancelled = true;
    };
  }, []);

  return { paket, loading };
}

/**
 * Hämtar frågorna i ett specifikt paket, i rätt ordning — utan facit.
 * Frågorna kommer via kartan_rundor_public (se 026_paket_schema.sql),
 * som medvetet exkluderar ratt_plats_id/ratt_lat/ratt_lon.
 */
export function usePaketFragor(paketId: string | null): {
  fragor: KartanPaketFraga[];
  loading: boolean;
} {
  const [fragor, setFragor] = useState<KartanPaketFraga[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!paketId) {
      setFragor([]);
      setLoading(false);
      return;
    }
    let cancelled = false;
    const supabase = createClient();

    async function fetchFragor() {
      setLoading(true);
      const { data: lankar } = await supabase
        .from("kartan_paket_rundor")
        .select("runda_id, ordning")
        .eq("paket_id", paketId)
        .order("ordning");

      if (!lankar || lankar.length === 0) {
        if (!cancelled) {
          setFragor([]);
          setLoading(false);
        }
        return;
      }

      const rundaIds = lankar.map((l) => l.runda_id);
      const { data: rundor } = await supabase
        .from("kartan_rundor_public")
        .select("id, titel, typ")
        .in("id", rundaIds);

      const rundaMap = Object.fromEntries((rundor ?? []).map((r) => [r.id, r]));

      const result: KartanPaketFraga[] = lankar
        .map((l) => {
          const r = rundaMap[l.runda_id];
          if (!r) return null;
          return { rundaId: r.id, titel: r.titel, typ: r.typ, ordning: l.ordning };
        })
        .filter((x): x is KartanPaketFraga => x !== null);

      if (!cancelled) {
        setFragor(result);
        setLoading(false);
      }
    }

    fetchFragor();
    return () => {
      cancelled = true;
    };
  }, [paketId]);

  return { fragor, loading };
}
