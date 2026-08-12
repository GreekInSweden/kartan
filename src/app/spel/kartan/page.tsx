"use client";

import { useState } from "react";
import Link from "next/link";
import { LanKlickGame } from "@/components/games/kartan/LanKlickGame";
import { NalgissningGame } from "@/components/games/kartan/NalgissningGame";

// TODO: hämta från er befintliga spelare/session-context istället för hårdkodning
const DEMO_SPELARE_ID = "00000000-0000-0000-0000-000000000000";

export default function KartanPage() {
  const [mode, setMode] = useState<"lan" | "punkt">("lan");

  return (
    <main className="min-h-screen bg-[#0b0e14] text-[#f2f0e8] flex flex-col">
      <div className="mx-auto max-w-5xl px-4 py-8 sm:py-10 flex-1 w-full">
        <p className="text-[11px] tracking-[0.18em] text-[#8b94a3] mb-2">
          KAN DU ALLA
        </p>
        <h1 className="text-2xl sm:text-3xl font-semibold mb-5">Kartan</h1>

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

        {mode === "lan" ? (
          <LanKlickGame spelareId={DEMO_SPELARE_ID} />
        ) : (
          <NalgissningGame spelareId={DEMO_SPELARE_ID} />
        )}
      </div>

      <footer className="px-4 py-4 text-center">
        <Link href="/admin/kartan" className="text-[11px] text-[#3a4250] hover:text-[#8b94a3]">
          Admin
        </Link>
      </footer>
    </main>
  );
}
