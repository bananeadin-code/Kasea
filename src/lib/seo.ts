// ============================================================================
// Helper de SEO reutilizable (TanStack Start `head()`).
//
// Centraliza title, description, canonical ABSOLUTO, Open Graph y Twitter para
// cada página, de forma mantenible y escalable. Uso en una ruta:
//
//   head: () => seo({
//     title: "Tienda — Kasea Store",
//     description: "…",
//     path: "/tienda",
//   }),
//
// Si el dominio cambia, se actualiza SOLO aquí (SITE_URL).
// ============================================================================

// Versión canónica única del dominio: apex, https, sin www.
export const SITE_URL = "https://kasea.es";

// Imagen por defecto para compartir en redes (Open Graph).
const DEFAULT_OG_IMAGE = `${SITE_URL}/brand/hero-kasea.png`;

export interface SeoInput {
  title: string;
  description: string;
  /** Ruta canónica, empezando por "/". Ej: "/", "/tienda". */
  path: string;
  /** Imagen OG (absoluta o ruta "/..."). Por defecto, la de marca. */
  image?: string;
  /** true => noindex,nofollow (páginas privadas). Por defecto index,follow. */
  noindex?: boolean;
}

function absolute(url: string): string {
  return url.startsWith("http") ? url : `${SITE_URL}${url.startsWith("/") ? "" : "/"}${url}`;
}

export function seo(input: SeoInput) {
  const canonical = `${SITE_URL}${input.path === "/" ? "/" : input.path}`;
  const image = absolute(input.image ?? DEFAULT_OG_IMAGE);

  return {
    meta: [
      { title: input.title },
      { name: "description", content: input.description },
      { name: "robots", content: input.noindex ? "noindex, nofollow" : "index, follow" },
      { property: "og:title", content: input.title },
      { property: "og:description", content: input.description },
      { property: "og:url", content: canonical },
      { property: "og:image", content: image },
      { name: "twitter:title", content: input.title },
      { name: "twitter:description", content: input.description },
      { name: "twitter:image", content: image },
    ],
    links: [{ rel: "canonical", href: canonical }],
  };
}
