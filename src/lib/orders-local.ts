// ============================================================================
// Historial de pedidos del CLIENTE — guardado localmente (sin cuentas).
//
// La tienda es de compra como invitado (no hay auth de cliente), así que el
// historial vive en localStorage. Guardamos solo un puntero mínimo por pedido;
// el estado real y el detalle se releen del servidor con el `stripe_session_id`
// (que actúa como token de acceso — solo lo conoce el navegador del comprador).
// ============================================================================

export interface StoredOrder {
  sessionId: string;
  savedAt: number; // epoch ms
  totalCents: number;
  currency: string;
  itemCount: number;
  firstTitle: string;
}

const KEY = "kasea-orders";
const MAX = 30;

export function getStoredOrders(): StoredOrder[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = localStorage.getItem(KEY);
    const arr = raw ? JSON.parse(raw) : [];
    return Array.isArray(arr) ? (arr as StoredOrder[]) : [];
  } catch {
    return [];
  }
}

// Añade (o actualiza) un pedido al principio de la lista. Idempotente por sessionId.
export function addStoredOrder(order: StoredOrder): void {
  if (typeof window === "undefined") return;
  try {
    const list = getStoredOrders().filter((o) => o.sessionId !== order.sessionId);
    list.unshift(order);
    localStorage.setItem(KEY, JSON.stringify(list.slice(0, MAX)));
  } catch {
    /* almacenamiento no disponible: se ignora sin romper la compra */
  }
}

// ---------------------------------------------------------------------------
// Estados de pedido — MISMOS valores que gestiona el admin (orders.status):
// 'pending' | 'paid' | 'fulfilled' | 'cancelled' | 'refunded'.
// Aquí se traducen a un texto amable para el cliente.
// ---------------------------------------------------------------------------
export type StatusTone = "positive" | "info" | "neutral" | "negative";

export function statusLabel(status: string): { label: string; tone: StatusTone } {
  switch (status) {
    case "paid":
      return { label: "Pago confirmado · preparando tu pedido", tone: "info" };
    case "fulfilled":
      return { label: "Enviado", tone: "positive" };
    case "cancelled":
      return { label: "Cancelado", tone: "negative" };
    case "refunded":
      return { label: "Reembolsado", tone: "neutral" };
    case "pending":
      return { label: "Pendiente de pago", tone: "neutral" };
    default:
      return { label: status || "En proceso", tone: "neutral" };
  }
}

// Clases Tailwind para la etiqueta de estado según su tono.
export function toneClasses(tone: StatusTone): string {
  switch (tone) {
    case "positive":
      return "bg-green-50 text-green-700 border-green-200";
    case "negative":
      return "bg-red-50 text-red-700 border-red-200";
    case "info":
      return "bg-secondary text-espresso border-border/60";
    default:
      return "bg-secondary text-muted-foreground border-border/60";
  }
}

// Formatea céntimos a moneda (es-ES). Centralizado para el historial y el éxito.
export function formatCents(cents: number, currency = "EUR"): string {
  try {
    return new Intl.NumberFormat("es-ES", { style: "currency", currency }).format(cents / 100);
  } catch {
    return `${(cents / 100).toFixed(2)} ${currency}`;
  }
}
