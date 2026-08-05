// ============================================================================
// Contenido editable de la web (textos por temporada).
//
// Fuente de verdad: tabla `site_content` (clave/valor) en Supabase, editable
// desde /admin/contenido. Aquí viven los valores POR DEFECTO (fallback) y la
// lista de campos que se muestran en el panel. Para añadir un texto editable:
//   1) añade su clave aquí (DEFAULTS + FIELDS),
//   2) siémbrala en la migración de site_content,
//   3) úsala en el componente con useSiteContent().
// ============================================================================
export type SiteContent = Record<string, string>;

export const SITE_CONTENT_DEFAULTS: SiteContent = {
  announcement_text: "Envío gratuito en pedidos superiores a 55€",
  hero_title_line1: "TU MOVIL MERECE",
  hero_title_line2: "una funda única",
  hero_intro:
    "En KASEA diseñamos exclusivamente fundas para iPhone. Elige tu modelo y, si no encuentras tu estilo, te lo creamos.",
  hero_cta: "Lo más vendido",
};

export interface SiteContentField {
  key: keyof typeof SITE_CONTENT_DEFAULTS & string;
  label: string;
  help?: string;
  multiline?: boolean;
}

// Orden y textos de ayuda tal como se muestran en el panel.
export const SITE_CONTENT_FIELDS: SiteContentField[] = [
  {
    key: "announcement_text",
    label: "Barra de anuncio (cinta superior)",
    help: "Frase que se desliza arriba del todo. Ej.: “Rebajas de primavera -20%”.",
  },
  { key: "hero_title_line1", label: "Portada · título (línea 1)" },
  { key: "hero_title_line2", label: "Portada · título (línea 2, en cursiva)" },
  {
    key: "hero_intro",
    label: "Portada · texto de introducción",
    multiline: true,
  },
  { key: "hero_cta", label: "Portada · texto del botón principal" },
];

// Combina las filas guardadas con los valores por defecto (nunca deja huecos).
export function withDefaults(rows: SiteContent | null | undefined): SiteContent {
  return { ...SITE_CONTENT_DEFAULTS, ...(rows ?? {}) };
}
