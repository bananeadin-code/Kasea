// ============================================================================
// Tipos y utilidades del PRODUCTO (forma que consume la UI).
//
// Nota: el nombre del archivo/tipo conserva "shopify" por compatibilidad con
// los imports existentes, pero YA NO hay ninguna dependencia de Shopify: no se
// llama a su API ni hay tokens. El catálogo vive en Supabase (ver
// src/lib/catalog.functions.ts), que devuelve exactamente esta misma forma.
// ============================================================================

export interface ShopifyImage {
  url: string;
  altText: string | null;
}

export interface ShopifyVariant {
  id: string;
  title: string;
  price: { amount: string; currencyCode: string };
  availableForSale: boolean;
  /** Stock disponible (fuente de verdad: Supabase). */
  quantityAvailable?: number | null;
  currentlyNotInStock?: boolean;
  selectedOptions: Array<{ name: string; value: string }>;
}

/** Disponibilidad real de una variante. */
export function isVariantAvailable(variant?: Partial<ShopifyVariant> | null): boolean {
  if (!variant) return false;
  if (variant.availableForSale) return true;
  return (variant.quantityAvailable ?? 0) > 0;
}

export function variantStockLabel(variant?: Partial<ShopifyVariant> | null): string {
  if (!isVariantAvailable(variant)) return "Agotado";
  const qty = variant?.quantityAvailable;
  if (typeof qty === "number" && qty > 0 && qty <= 5) return `Últimas ${qty} unidades`;
  return "En stock";
}

export interface ShopifyProduct {
  node: {
    id: string;
    title: string;
    description: string;
    handle: string;
    tags?: string[];
    collections?: { edges: Array<{ node: { title: string; handle: string } }> };
    priceRange: { minVariantPrice: { amount: string; currencyCode: string } };
    images: { edges: Array<{ node: ShopifyImage }> };
    variants: { edges: Array<{ node: ShopifyVariant }> };
    options: Array<{ name: string; values: string[] }>;
  };
}

export function formatPrice(amount: string | number, currencyCode = "EUR") {
  const n = typeof amount === "string" ? parseFloat(amount) : amount;
  try {
    return new Intl.NumberFormat("es-ES", {
      style: "currency",
      currency: currencyCode,
      minimumFractionDigits: 2,
    }).format(n);
  } catch {
    return `${n.toFixed(2)} ${currencyCode}`;
  }
}
