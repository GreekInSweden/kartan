import { NextRequest, NextResponse } from "next/server";
import { createAdminClient, checkAdminPassword } from "@/lib/supabase/admin";

export async function POST(request: NextRequest) {
  const body = await request.json();
  const {
    adminPassword,
    kategoriId,
    titel,
    typ,
    rattPlatsId,
    rattLat,
    rattLon,
    toleransKm,
    visadVarde,
  } = body;

  if (!checkAdminPassword(adminPassword)) {
    return NextResponse.json({ error: "Fel lösenord." }, { status: 401 });
  }

  if (!kategoriId || !titel || !visadVarde || !typ || !["lan", "punkt"].includes(typ)) {
    return NextResponse.json(
      { error: "kategoriId, titel, visadVarde och giltig typ krävs." },
      { status: 400 }
    );
  }

  if (typ === "lan" && !rattPlatsId) {
    return NextResponse.json(
      { error: "rattPlatsId krävs för länsklick-rundor (klicka på kartan)." },
      { status: 400 }
    );
  }

  if (typ === "punkt" && (rattLat == null || rattLon == null)) {
    return NextResponse.json(
      { error: "rattLat/rattLon krävs för nålgissnings-rundor (klicka på kartan)." },
      { status: 400 }
    );
  }

  const supabase = createAdminClient();

  // Bara en aktiv runda per kategori i taget — inaktivera ev. tidigare aktiva rundor
  // i samma kategori innan den nya skapas, så admin inte behöver hålla koll manuellt.
  const { error: deactivateError } = await supabase
    .from("kartan_rundor")
    .update({ is_aktiv: false })
    .eq("kategori_id", kategoriId)
    .eq("is_aktiv", true);

  if (deactivateError) {
    return NextResponse.json({ error: deactivateError.message }, { status: 500 });
  }

  const { data, error } = await supabase
    .from("kartan_rundor")
    .insert({
      kategori_id: kategoriId,
      titel,
      typ,
      ratt_plats_id: typ === "lan" ? rattPlatsId : null,
      ratt_lat: typ === "punkt" ? rattLat : null,
      ratt_lon: typ === "punkt" ? rattLon : null,
      tolerans_km: typ === "punkt" ? (toleransKm ?? 15) : null,
      visad_varde: visadVarde,
      is_aktiv: true,
    })
    .select()
    .single();

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({ runda: data });
}
