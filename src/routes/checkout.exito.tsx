import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect } from "react";
import { CheckCircle2, Package } from "lucide-react";
import { useCartStore } from "@/lib/cart";

export const Route = createFileRoute("/checkout/exito")({
  validateSearch: (search: Record<string, unknown>): { session_id?: string } =>
    typeof search.session_id === "string" ? { session_id: search.session_id } : {},
  head: () => ({
    meta: [
      { title: "¡Gracias por tu compra! — Kasea Store" },
      { name: "robots", content: "noindex" },
    ],
  }),
  component: CheckoutSuccessPage,
});

function CheckoutSuccessPage() {
  const clearCart = useCartStore((s) => s.clearCart);

  // El pago ya se completó en Stripe (solo se llega aquí tras éxito): vaciamos
  // la bolsa local. La confirmación real del pedido y el correo los gestiona
  // el webhook en el servidor (Fase 4), que es la fuente de verdad.
  useEffect(() => {
    clearCart();
  }, [clearCart]);

  return (
    <div className="container-luxe py-24 text-center">
      <CheckCircle2 className="mx-auto h-16 w-16 text-espresso" strokeWidth={1.25} />
      <h1 className="mt-6 font-display text-4xl md:text-5xl">¡Gracias por tu compra!</h1>
      <p className="mx-auto mt-4 max-w-md text-muted-foreground">
        Tu pago se ha completado correctamente. Estamos confirmando tu pedido y te enviaremos
        un correo de confirmación en cuanto esté listo.
      </p>

      <div className="mx-auto mt-8 flex max-w-md items-start gap-3 rounded-xl border border-border/60 bg-card p-5 text-left">
        <Package className="mt-0.5 h-5 w-5 flex-shrink-0 text-espresso" strokeWidth={1.5} />
        <p className="text-sm text-muted-foreground">
          Prepararemos tu pedido con cuidado. Si tienes cualquier duda, escríbenos desde la página
          de contacto y te ayudamos enseguida.
        </p>
      </div>

      <div className="mt-10 flex flex-wrap justify-center gap-3">
        <Link
          to="/tienda"
          className="inline-flex h-12 items-center gap-2 rounded-md bg-espresso px-7 text-sm font-medium uppercase tracking-[0.14em] text-ivory transition-transform hover:-translate-y-0.5"
        >
          Seguir comprando
        </Link>
        <Link
          to="/"
          className="inline-flex h-12 items-center gap-2 rounded-md border border-border px-7 text-sm font-medium uppercase tracking-[0.14em] transition-colors hover:bg-secondary"
        >
          Volver al inicio
        </Link>
      </div>
    </div>
  );
}
