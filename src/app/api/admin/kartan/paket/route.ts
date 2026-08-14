import { NextRequest, NextResponse } from "next/server";
import { createAdminClient, checkAdminPassword } from "@/lib/supabase/admin";

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const {
    adminPassword,
    namn,
    antalKommun = 5,
    antalPunkt = 5,
    kategoriIds, // valfri: string[] — om satt hämtas ENDAST från dessa kategorier (temapaket)
  } = body;

  if (!checkAdminPassword(adminPassword)) {
    return NextResponse.json({ error: "Fel lösenord." }, { status: 401 });
  }

  const supabase = createAdminClient();

  // Rundor som redan ligger i NÅGOT paket (oavsett publicerat eller ej)
  // ska inte kunna hamna i ett nytt paket också — varje fråga hör bara
  // hemma i ett paket, så spelare aldrig ser samma fråga två gånger.
  const { data: redanAnvanda, error: usedError } = await supabase
    .from("kartan_paket_rundor")
    .select("runda_id");
  if (usedError) return NextResponse.json({ error: usedError.message }, { status: 500 });
  const uteslut = (redanAnvanda ?? []).map((r) => r.runda_id);

  const temaFilter = Array.isArray(kategoriIds) && kategoriIds.length > 0 ? kategoriIds : null;

  async function plockaSlumpade(typ: "kommun" | "punkt", antal: number) {
    if (antal <= 0) return [];
    let query = supabase.from("kartan_rundor").select("id").eq("typ", typ).eq("is_aktiv", true);
    if (temaFilter) query = query.in("kategori_id", temaFilter);
    if (uteslut.length > 0) {
      query = query.not("id", "in", `(${uteslut.join(",")})`);
    }
    const { data, error } = await query;
    if (error) throw new Error(error.message);
    return shuffle(data ?? []).slice(0, antal);
  }

  let kommunRundor, punktRundor;
  try {
    kommunRundor = await plockaSlumpade("kommun", antalKommun);
    punktRundor = await plockaSlumpade("punkt", antalPunkt);
  } catch (e) {
    return NextResponse.json({ error: (e as Error).message }, { status: 500 });
  }

  if (kommunRundor.length < antalKommun || punktRundor.length < antalPunkt) {
    return NextResponse.json(
      {
        error: `Inte tillräckligt med oanvända rundor kvar (hittade ${kommunRundor.length} kommun, ${punktRundor.length} punkt — behöver ${antalKommun} respektive ${antalPunkt}).`,
      },
      { status: 400 }
    );
  }

  const { data: nyttPaket, error: paketError } = await supabase
    .from("kartan_paket")
    .insert({ namn: namn || `Paket ${new Date().toISOString().slice(0, 10)}`, status: "utkast" })
    .select()
    .single();

  if (paketError) return NextResponse.json({ error: paketError.message }, { status: 500 });

  // Blanda kommun- och punkt-frågorna så de inte kommer i två klumpar
  const blandat = shuffle([...kommunRundor, ...punktRundor]);
  const rows = blandat.map((r, i) => ({
    paket_id: nyttPaket.id,
    runda_id: r.id,
    ordning: i + 1,
  }));

  const { error: insertError } = await supabase.from("kartan_paket_rundor").insert(rows);
  if (insertError) return NextResponse.json({ error: insertError.message }, { status: 500 });

  return NextResponse.json({ paket: nyttPaket });
}
