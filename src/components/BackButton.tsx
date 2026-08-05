import { useRouter, useRouterState } from "@tanstack/react-router";
import { ChevronLeft } from "lucide-react";

export function BackButton() {
  const router = useRouter();
  const pathname = useRouterState({ select: (s) => s.location.pathname });

  // No mostrar en la home
  if (pathname === "/") return null;

  const handleBack = () => {
    if (typeof window !== "undefined" && window.history.length > 1) {
      router.history.back();
    } else {
      router.navigate({ to: "/" });
    }
  };

  return (
    <div className="container-luxe pt-4">
      <button
        type="button"
        onClick={handleBack}
        aria-label="Volver a la página anterior"
        className="inline-flex items-center gap-1.5 rounded-full border border-border/60 bg-background px-3 py-1.5 text-xs font-medium tracking-wide text-foreground/80 transition-colors hover:bg-secondary hover:text-foreground"
      >
        <ChevronLeft className="h-3.5 w-3.5" strokeWidth={2} />
        Volver
      </button>
    </div>
  );
}
