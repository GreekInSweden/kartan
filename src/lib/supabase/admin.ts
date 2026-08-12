import { createClient as createSupabaseClient } from "@supabase/supabase-js";

/**
 * ADMIN-klient — använder den hemliga/service_role-nyckeln och kringgår RLS helt.
 *
 * VIKTIGT: importeras ENDAST i API-routes (src/app/api/**) som körs server-side.
 * Får ALDRIG importeras i en "use client"-komponent eller i något som bunt-as
 * till webbläsaren — då skulle den hemliga nyckeln läcka till alla besökare.
 *
 * Kräver SUPABASE_SECRET_KEY som miljövariabel (INTE NEXT_PUBLIC_-prefixad),
 * satt på Vercel under Settings → Environment Variables, och lokalt i .env.local.
 * Hämta nyckeln från Supabase Dashboard → Project Settings → API Keys →
 * "Secret keys" (eller den äldre service_role-nyckeln om projektet inte
 * migrerats till de nya nyckeltyperna än).
 */
export function createAdminClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const secretKey = process.env.SUPABASE_SECRET_KEY;

  if (!url || !secretKey) {
    throw new Error(
      "SUPABASE_SECRET_KEY (eller NEXT_PUBLIC_SUPABASE_URL) saknas i miljövariablerna."
    );
  }

  return createSupabaseClient(url, secretKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}

/**
 * Enkel jämförelse av admin-lösenordet mot ADMIN_PASSWORD i miljövariablerna.
 * Kräver ADMIN_PASSWORD satt server-side (INTE NEXT_PUBLIC_-prefixad).
 */
export function checkAdminPassword(providedPassword: string): boolean {
  const real = process.env.ADMIN_PASSWORD;
  if (!real) return false;
  return providedPassword === real;
}
