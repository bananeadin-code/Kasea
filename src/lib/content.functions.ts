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
  const { data, error } = await (supabase as any).from("site_content").select("key, value, updated_at");
  // Si la tabla aún no existe (migración sin aplicar) o falla, usamos los valores por defecto.
  if (error) return withDefaults(null);
  const map: SiteContent = {};
  // Fecha de última edición LEGAL (para "última actualización" de Términos/Privacidad).
  let legalUpdated = "";
  for (const r of (data ?? []) as Array<{ key: string; value: string; updated_at: string }>) {
    map[r.key] = r.value;
    if (r.key.startsWith("legal_") && r.updated_at && r.updated_at > legalUpdated) {
      legalUpdated = r.updated_at;
    }
  }
  const result = withDefaults(map);
  if (legalUpdated) result.__legal_updated_at = legalUpdated;
  return result;
});
