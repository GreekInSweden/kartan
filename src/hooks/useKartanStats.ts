"use client";

import { useEffect, useState } from "react";
import type { KartanSpeltyp } from "@/types/kartan";

export interface KartanStats {
  totaltAntal: number;
  spelade: number;
  kvarAntal: number;
  snittPoang: number;
  bastaPoang: number;
}

export function useKartanStats(
  spelareId: string,
  typ: KartanSpeltyp,
  refreshKey: number = 0
): { stats: KartanStats | null; loading: boolean } {
  const [stats, setStats] = useState<KartanStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    async function fetchStats() {
      setLoading(true);
      try {
        const res = await fetch(
          `/api/kartan/stats?spelareId=${encodeURIComponent(spelareId)}&typ=${typ}`
        );
        const data = await res.json();
        if (!cancelled && res.ok) setStats(data);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    fetchStats();
    return () => {
      cancelled = true;
    };
  }, [spelareId, typ, refreshKey]);

  return { stats, loading };
}
