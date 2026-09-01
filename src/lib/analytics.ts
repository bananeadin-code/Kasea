// ============================================================================
// Google Analytics 4 con CONSENTIMIENTO (RGPD).
//
// La tienda es española (UE): GA solo se activa si el usuario ACEPTA cookies.
// El Measurement ID vive en una variable de entorno pública (VITE_GA_ID); si no
// está configurada, GA queda deshabilitado y no se muestra el banner.
// ============================================================================
const GA_ID = import.meta.env.VITE_GA_ID as string | undefined;
const CONSENT_KEY = "kasea-cookie-consent"; // "accepted" | "rejected"

export const GA_ENABLED = !!GA_ID;

export type Consent = "accepted" | "rejected";

export function getConsent(): Consent | null {
  if (typeof window === "undefined") return null;
  try {
    const v = localStorage.getItem(CONSENT_KEY);
    return v === "accepted" || v === "rejected" ? v : null;
  } catch {
    return null;
  }
}

export function setConsent(v: Consent): void {
  try {
    localStorage.setItem(CONSENT_KEY, v);
  } catch {
    /* almacenamiento no disponible */
  }
}

// Permite volver a mostrar el banner (retirar/cambiar consentimiento).
export function resetConsent(): void {
  try {
    localStorage.removeItem(CONSENT_KEY);
  } catch {
    /* ignore */
  }
}

let gaLoaded = false;

// Carga gtag.js UNA vez. No envía page_view automático: lo controlamos por ruta.
export function loadGa(): void {
  if (gaLoaded || !GA_ID || typeof window === "undefined") return;
  gaLoaded = true;

  const s = document.createElement("script");
  s.async = true;
  s.src = `https://www.googletagmanager.com/gtag/js?id=${GA_ID}`;
  document.head.appendChild(s);

  const w = window as unknown as { dataLayer: unknown[]; gtag: (...args: unknown[]) => void };
  w.dataLayer = w.dataLayer || [];
  w.gtag = function gtag(...args: unknown[]) {
    w.dataLayer.push(args);
  };
  w.gtag("js", new Date());
  w.gtag("config", GA_ID, { send_page_view: false, anonymize_ip: true });
}

// page_view manual (SPA): se llama en cada cambio de ruta, solo con consentimiento.
export function trackPageView(path: string): void {
  const w = window as unknown as { gtag?: (...args: unknown[]) => void };
  if (!GA_ID || typeof w.gtag !== "function") return;
  w.gtag("event", "page_view", {
    page_path: path,
    page_location: window.location.href,
    page_title: document.title,
  });
}
