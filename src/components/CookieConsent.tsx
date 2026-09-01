import { useEffect, useState } from "react";
import { Link, useRouterState } from "@tanstack/react-router";
import { Button } from "@/components/ui/button";
import { getConsent, setConsent, loadGa, trackPageView, GA_ENABLED, type Consent } from "@/lib/analytics";

// Banner de cookies + arranque de Google Analytics tras consentimiento.
// GA se carga SOLO si el usuario acepta; el page_view se dispara en cada ruta.
export function CookieConsent() {
  // undefined = aún no leído (SSR / primer render); null = sin elección todavía.
  const [choice, setChoice] = useState<Consent | null | undefined>(undefined);
  const pathname = useRouterState({ select: (s) => s.location.pathname });

  useEffect(() => {
    const saved = getConsent();
    setChoice(saved);
    if (saved === "accepted") loadGa();
  }, []);

  // page_view en cada cambio de ruta, solo con consentimiento.
  useEffect(() => {
    if (choice === "accepted") trackPageView(pathname);
  }, [pathname, choice]);

  function accept() {
    setConsent("accepted");
    loadGa();
    setChoice("accepted"); // dispara el page_view inicial vía el efecto de arriba
  }
  function reject() {
    setConsent("rejected");
    setChoice("rejected");
  }

  // Sin GA configurado, o durante SSR, o si ya eligió: no mostrar banner.
  if (!GA_ENABLED || choice === undefined || choice !== null) return null;

  return (
    <div className="fixed inset-x-0 bottom-0 z-50 border-t border-border bg-background/95 backdrop-blur-md">
      <div className="container-luxe flex flex-col gap-3 py-4 sm:flex-row sm:items-center sm:justify-between">
        <p className="max-w-2xl text-xs leading-relaxed text-muted-foreground">
          Usamos cookies de <strong className="text-foreground">Google Analytics</strong> para entender
          cómo se usa la web y mejorarla. No se activan sin tu permiso. Consulta la{" "}
          <Link to="/privacidad" className="underline hover:text-foreground">
            Política de Privacidad
          </Link>
          .
        </p>
        <div className="flex flex-shrink-0 gap-2">
          <Button variant="outline" size="sm" onClick={reject}>
            Rechazar
          </Button>
          <Button size="sm" onClick={accept}>
            Aceptar
          </Button>
        </div>
      </div>
    </div>
  );
}
