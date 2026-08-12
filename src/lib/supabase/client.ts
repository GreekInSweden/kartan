import { createBrowserClient } from "@supabase/ssr";

/**
 * Supabase-klient för klient-sidan (React-komponenter, hooks).
 * Läser URL och publishable/anon-nyckel från miljövariabler — se .env.local.
 */
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
