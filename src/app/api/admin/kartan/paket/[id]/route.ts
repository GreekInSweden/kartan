import { NextRequest, NextResponse } from "next/server";
import { createAdminClient, checkAdminPassword } from "@/lib/supabase/admin";

export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const body = await request.json();
  const { adminPassword, status } = body;

  if (!checkAdminPassword(adminPassword)) {
    return NextResponse.json({ error: "Fel lösenord." }, { status: 401 });
  }

  if (!["utkast", "publicerad"].includes(status)) {
    return NextResponse.json({ error: "status måste vara 'utkast' eller 'publicerad'." }, { status: 400 });
  }

  const supabase = createAdminClient();
  const { data, error } = await supabase
    .from("kartan_paket")
    .update({ status })
    .eq("id", id)
    .select()
    .single();

  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ paket: data });
}
