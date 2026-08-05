// ============================================================================
// Lectura pública del contenido editable de la web (textos por temporada).
// Usa la publishable key (RLS permite lectura pública de site_content).
// ============================================================================
import { createServerFn } from "@tanstack/react-start";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";
import { withDefaults, type SiteContent } from "@/lib/site-content";

function publicClient() {
  return createClient<Database>(process.env.SUPABASE_URL!, process.env.SUPABASE_PUBLISHABLE_KEY!, {
    auth: { storage: undefined, persistSession: false, autoRefreshToken: false },
  });
}

export const getSiteContent = createServerFn({ method: "GET" }).handler(async (): Promise<SiteContent> => {
  const supabase = publicClient();
  const { data, error } = await (supabase as any).from("site_content").select("key, value");
  // Si la tabla aún no existe (migración sin aplicar) o falla, usamos los valores por defecto.
  if (error) return withDefaults(null);
  const map: SiteContent = {};
  for (const r of (data ?? []) as Array<{ key: string; value: string }>) map[r.key] = r.value;
  return withDefaults(map);
});
