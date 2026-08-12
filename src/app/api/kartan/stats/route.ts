import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";

/**
 * Läser statistik för en spelare — antal rundor spelade, snittpoäng, bästa
 * resultat, samt hur många av de just nu aktiva rundorna som återstår.
 *
 * Använder admin-klienten (samma hemliga nyckel som admin-gränssnittet) för
 * att kringgå RLS, eftersom det ännu inte finns en riktig inloggning kopplad
 * till spelare_id — RLS-policyn för kartan_gissningar kräver auth.uid(),
 * vilket alltid är null utan en riktig session. Detta är en medveten
 * övergångslösning: när ni kopplar in riktiga spelarkonton bör den här
 * routen bytas mot en vanlig klient-läsning skyddad av RLS istället.
 */
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const spelareId = searchParams.get("spelareId");
  const typ = searchParams.get("typ");

  if (!spelareId || !typ || !["lan", "kommun", "punkt"].includes(typ)) {
    return NextResponse.json({ error: "spelareId och giltig typ krävs." }, { status: 400 });
  }

  const supabase = createAdminClient();

  const { data: aktivaRundor, error: rundorError } = await supabase
    .from("kartan_rundor")
    .select("id")
    .eq("typ", typ)
    .eq("is_aktiv", true);

  if (rundorError) {
    return NextResponse.json({ error: rundorError.message }, { status: 500 });
  }

  const aktivaIds = (aktivaRundor ?? []).map((r) => r.id);
  const totaltAntal = aktivaIds.length;

  if (totaltAntal === 0) {
    return NextResponse.json({
      totaltAntal: 0,
      spelade: 0,
      kvarAntal: 0,
      snittPoang: 0,
      bastaPoang: 0,
    });
  }

  const { data: gissningar, error: gissningarError } = await supabase
    .from("kartan_gissningar")
    .select("poang, runda_id")
    .eq("spelare_id", spelareId)
    .in("runda_id", aktivaIds);

  if (gissningarError) {
    return NextResponse.json({ error: gissningarError.message }, { status: 500 });
  }

  const poangLista = (gissningar ?? []).map((g) => g.poang);
  const spelade = poangLista.length;
  const snittPoang = spelade > 0 ? Math.round(poangLista.reduce((a, b) => a + b, 0) / spelade) : 0;
  const bastaPoang = spelade > 0 ? Math.max(...poangLista) : 0;

  return NextResponse.json({
    totaltAntal,
    spelade,
    kvarAntal: totaltAntal - spelade,
    snittPoang,
    bastaPoang,
  });
}
