import { NextRequest, NextResponse } from "next/server";
import { createAdminClient, checkAdminPassword } from "@/lib/supabase/admin";

export async function POST(request: NextRequest) {
  const body = await request.json();
  const { adminPassword, namn, beskrivning, typ } = body;

  if (!checkAdminPassword(adminPassword)) {
    return NextResponse.json({ error: "Fel lösenord." }, { status: 401 });
  }

  if (!namn || !typ || !["lan", "kommun", "punkt"].includes(typ)) {
    return NextResponse.json({ error: "namn och giltig typ krävs." }, { status: 400 });
  }

  const supabase = createAdminClient();
  const { data, error } = await supabase
    .from("kartan_kategorier")
    .insert({ namn, beskrivning: beskrivning || null, typ })
    .select()
    .single();

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({ kategori: data });
}
