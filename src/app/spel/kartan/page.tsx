"use client";

import { useState } from "react";
import { usePubliceradePaket } from "@/hooks/useKartanPaket";
import { PaketSpel } from "@/components/games/kartan/PaketSpel";

// TODO: hämta från er befintliga spelare/session-context istället för hårdkodning
const DEMO_SPELARE_ID = "00000000-0000-0000-0000-000000000000";

export default function KartanPage() {
  const { paket, loading } = usePubliceradePaket();
  const [aktivtPaketId, setAktivtPaketId] = useState<string | null>(null);

  const aktivtPaket = paket.find((p) => p.id === aktivtPaketId);

  return (
    <main className="min-h-screen bg-[#0b0e14] text-[#f2f0e8] flex flex-col">
      <div className="mx-auto max-w-5xl px-4 py-8 sm:py-10 flex-1 w-full">
        <p className="text-[11px] tracking-[0.18em] text-[#8b94a3] mb-2">KAN DU ALLA</p>
        <h1 className="text-2xl sm:text-3xl font-semibold mb-8">Kartan</h1>

        {aktivtPaket ? (
          <PaketSpel
            paketId={aktivtPaket.id}
            paketNamn={aktivtPaket.namn}
            spelareId={DEMO_SPELARE_ID}
            onKlar={() => setAktivtPaketId(null)}
          />
        ) : (
          <>
            {loading && <p style={{ color: "#8b94a3" }}>Laddar paket…</p>}

            {!loading && paket.length === 0 && (
              <p style={{ color: "#8b94a3" }}>
                Inga paket är publicerade just nu — kom tillbaka snart!
              </p>
            )}

            <div className="grid gap-4 sm:grid-cols-2 md:grid-cols-3">
              {paket.map((p) => (
                <button
                  key={p.id}
                  onClick={() => setAktivtPaketId(p.id)}
                  className="text-left rounded-xl border border-[#232a36] bg-[#12161f] p-5 hover:border-[#e8b84b] transition-colors"
                >
                  <p className="text-[10px] tracking-[0.12em] text-[#8b94a3] mb-2">PAKET</p>
                  <p className="text-lg font-semibold mb-3">{p.namn}</p>
                  <p className="text-xs text-[#e8b84b]">Spela → 10 frågor</p>
                </button>
              ))}
            </div>
          </>
        )}
      </div>
    </main>
  );
}
