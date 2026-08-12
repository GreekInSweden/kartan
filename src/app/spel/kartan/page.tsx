"use client";

import { useState } from "react";
import { LanKlickGame } from "@/components/games/kartan/LanKlickGame";
import { NalgissningGame } from "@/components/games/kartan/NalgissningGame";

// TODO: hämta från er befintliga spelare/session-context istället för hårdkodning
const DEMO_SPELARE_ID = "00000000-0000-0000-0000-000000000000";

// TODO: byt ut mot riktiga kategori-id:n från kartan_kategorier när ni seedat innehåll
const DEMO_KATEGORI_LAN = "REPLACE_WITH_REAL_KATEGORI_ID";
const DEMO_KATEGORI_PUNKT = "REPLACE_WITH_REAL_KATEGORI_ID";

export default function KartanPage() {
  const [mode, setMode] = useState<"lan" | "punkt">("lan");

  return (
    <main style={{ maxWidth: 460, margin: "0 auto", padding: "24px 16px" }}>
      <h1>Kartan</h1>

      <div style={{ display: "flex", gap: 8, marginBottom: 16 }}>
        <button onClick={() => setMode("lan")} disabled={mode === "lan"}>
          Länsklick
        </button>
        <button onClick={() => setMode("punkt")} disabled={mode === "punkt"}>
          Nålgissning
        </button>
      </div>

      {mode === "lan" ? (
        <LanKlickGame kategoriId={DEMO_KATEGORI_LAN} spelareId={DEMO_SPELARE_ID} />
      ) : (
        <NalgissningGame kategoriId={DEMO_KATEGORI_PUNKT} spelareId={DEMO_SPELARE_ID} />
      )}
    </main>
  );
}
