import { NextRequest, NextResponse } from "next/server";
import { createAdminClient, checkAdminPassword } from "@/lib/supabase/admin";

/**
 * Returnerar allt admin-sidan behöver: kategorier, rundor (MED facit-
 * kolumner), paket och vilka rundor som ingår i respektive paket.
 * Använder den hemliga nyckeln (kringgår RLS) eftersom kartan_rundor
 * inte längre är publikt läsbar — se 026_paket_schema.sql.
 */
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const adminPassword = searchParams.get("adminPassword") ?? "";

  if (!checkAdminPassword(adminPassword)) {
    return NextResponse.json({ error: "Fel lösenord." }, { status: 401 });
  }

  const supabase = createAdminClient();

  const { data: kategorier, error: katError } = await supabase
    .from("kartan_kategorier")
    .select("id, namn, beskrivning, typ")
    .order("namn");
  if (katError) return NextResponse.json({ error: katError.message }, { status: 500 });

  const { data: rundor, error: rundorError } = await supabase
    .from("kartan_rundor")
    .select("id, kategori_id, titel, typ, is_aktiv, visad_varde, ratt_plats_id, ratt_lat, ratt_lon")
    .order("skapad_at", { ascending: false });
  if (rundorError) return NextResponse.json({ error: rundorError.message }, { status: 500 });

  const { data: paket, error: paketError } = await supabase
    .from("kartan_paket")
    .select("id, namn, status, skapad_at")
    .order("skapad_at", { ascending: false });
  if (paketError) return NextResponse.json({ error: paketError.message }, { status: 500 });

  const { data: paketRundor, error: prError } = await supabase
    .from("kartan_paket_rundor")
    .select("paket_id, runda_id, ordning")
    .order("ordning");
  if (prError) return NextResponse.json({ error: prError.message }, { status: 500 });

  return NextResponse.json({ kategorier, rundor, paket, paketRundor });
}
