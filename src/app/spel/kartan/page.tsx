"use client";

import { useState } from "react";
import { LanKlickGame } from "@/components/games/kartan/LanKlickGame";
import { NalgissningGame } from "@/components/games/kartan/NalgissningGame";

// TODO: hämta från er befintliga spelare/session-context istället för hårdkodning
const DEMO_SPELARE_ID = "00000000-0000-0000-0000-000000000000";

// Riktiga kategori-id:n (byt ut om ni skapar nya testkategorier)
const DEMO_KATEGORI_LAN = "f2adc7b0-0983-4641-9641-55a796586f53";
const DEMO_KATEGORI_PUNKT = "184b26e5-dd6f-4153-a6c3-6e4cf520526c";

export default function KartanPage() {
  const [mode, setMode] = useState<"lan" | "punkt">("lan");

  return (
    <main className="min-h-screen bg-[#0b0e14] text-[#f2f0e8]">
      <div className="mx-auto max-w-3xl px-4 py-10 sm:py-14">
        <p className="text-[11px] tracking-[0.18em] text-[#8b94a3] mb-2">
          KAN DU ALLA
        </p>
        <h1 className="text-3xl sm:text-4xl font-semibold mb-6">Kartan</h1>

        <div className="flex gap-2 mb-8">
          <button
            onClick={() => setMode("lan")}
            className={`px-4 py-2 rounded-lg text-sm tracking-wide border transition-colors ${
              mode === "lan"
                ? "border-[#e8b84b] bg-[#e8b84b1a] text-[#e8b84b]"
                : "border-[#232a36] text-[#8b94a3] hover:border-[#3a4250]"
            }`}
          >
            Länsklick
          </button>
          <button
            onClick={() => setMode("punkt")}
            className={`px-4 py-2 rounded-lg text-sm tracking-wide border transition-colors ${
              mode === "punkt"
                ? "border-[#e8b84b] bg-[#e8b84b1a] text-[#e8b84b]"
                : "border-[#232a36] text-[#8b94a3] hover:border-[#3a4250]"
            }`}
          >
            Nålgissning
          </button>
        </div>

        <div className="max-w-xl mx-auto sm:mx-0">
          {mode === "lan" ? (
            <LanKlickGame kategoriId={DEMO_KATEGORI_LAN} spelareId={DEMO_SPELARE_ID} />
          ) : (
            <NalgissningGame kategoriId={DEMO_KATEGORI_PUNKT} spelareId={DEMO_SPELARE_ID} />
          )}
        </div>
      </div>
    </main>
  );
}
