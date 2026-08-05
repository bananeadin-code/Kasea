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
  status?: string; // último estado conocido (para poder purgar sin consultar)
}

const KEY = "kasea-orders";
const MAX = 30;
const PRUNE_AFTER_MS = 30 * 24 * 60 * 60 * 1000; // 30 días

// Purga pedidos ya ENTREGADOS con más de 30 días: dejan de ser útiles en el
// historial del cliente. El resto (enviado, pagado, etc.) se conserva.
function prune(list: StoredOrder[], now: number): StoredOrder[] {
  return list.filter((o) => !(o.status === "delivered" && now - o.savedAt > PRUNE_AFTER_MS));
}

export function getStoredOrders(): StoredOrder[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = localStorage.getItem(KEY);
    const arr = raw ? JSON.parse(raw) : [];
    if (!Array.isArray(arr)) return [];
    const pruned = prune(arr as StoredOrder[], Date.now());
    if (pruned.length !== arr.length) localStorage.setItem(KEY, JSON.stringify(pruned));
    return pruned;
  } catch {
    return [];
  }
}

// Actualiza el último estado conocido de un pedido en el historial local.
// Al persistirse, permite que la purga de entregados +30 días funcione aunque
// el cliente no vuelva a abrir la página de éxito.
export function syncStoredOrderStatus(sessionId: string, status: string): void {
  if (typeof window === "undefined") return;
  try {
    const list = getStoredOrders();
    let changed = false;
    const next = list.map((o) => {
      if (o.sessionId === sessionId && o.status !== status) {
        changed = true;
        return { ...o, status };
      }
      return o;
    });
    if (changed) localStorage.setItem(KEY, JSON.stringify(next));
  } catch {
    /* almacenamiento no disponible: se ignora */
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
      return { label: "Enviado", tone: "info" };
    case "delivered":
      return { label: "Entregado", tone: "positive" };
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
