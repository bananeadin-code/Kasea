import { useQuery } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { getSiteContent } from "@/lib/content.functions";
import { SITE_CONTENT_DEFAULTS, type SiteContent } from "@/lib/site-content";

// Contenido editable de la web. Mientras carga (o si falla), usa los valores
// por defecto, de modo que la página siempre muestra un texto coherente.
export function useSiteContent(): SiteContent {
  const fn = useServerFn(getSiteContent);
  const { data } = useQuery({
    queryKey: ["site-content"],
    queryFn: () => fn(),
    staleTime: 5 * 60_000,
  });
  return data ?? SITE_CONTENT_DEFAULTS;
}
