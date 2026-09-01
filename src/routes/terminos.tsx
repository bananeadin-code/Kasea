import { createFileRoute } from "@tanstack/react-router";
import { seo } from "@/lib/seo";

export const Route = createFileRoute("/terminos")({
  head: () =>
    seo({
      title: "Términos y Condiciones — Kasea Store",
      description: "Términos y condiciones de compra de Kasea Store.",
      path: "/terminos",
    }),
  component: TerminosPage,
});

// NOTA: texto base orientativo para una tienda de e-commerce en España.
// Los valores entre [CORCHETES] debe rellenarlos/validarlos el titular (Julián),
// idealmente con revisión legal antes de darle carácter definitivo.
function TerminosPage() {
  return (
    <div className="container-luxe max-w-3xl py-16 md:py-24">
      <h1 className="font-display text-4xl md:text-5xl">Términos y Condiciones</h1>
      <p className="mt-3 text-sm text-muted-foreground">Última actualización: [FECHA]</p>

      <div className="prose-legal mt-10 space-y-8 text-sm leading-relaxed text-foreground/85">
        <section>
          <h2 className="mb-2 font-display text-xl text-foreground">1. Identificación del titular</h2>
          <p>
            Este sitio web es titularidad de <strong>[RAZÓN SOCIAL / NOMBRE Y APELLIDOS]</strong>, con
            NIF/DNI <strong>[NIF/DNI]</strong>, domicilio en <strong>[DIRECCIÓN COMPLETA]</strong> y
            correo de contacto <strong>[EMAIL DE CONTACTO]</strong> (en adelante, "Kasea").
          </p>
        </section>

        <section>
          <h2 className="mb-2 font-display text-xl text-foreground">2. Objeto</h2>
          <p>
            Estas condiciones regulan el uso de la web y la compra de productos (fundas para iPhone,
            incluidas fundas personalizadas) a través de la tienda online de Kasea.
          </p>
        </section>

        <section>
          <h2 className="mb-2 font-display text-xl text-foreground">3. Productos y precios</h2>
          <p>
            Los precios se muestran en euros (€) e incluyen el IVA aplicable. Kasea puede modificar los
            precios en cualquier momento; se aplicará el vigente en el momento de realizar el pedido.
            Las imágenes son orientativas.
          </p>
        </section>

        <section>
          <h2 className="mb-2 font-display text-xl text-foreground">4. Proceso de compra y pago</h2>
          <p>
            El pago con tarjeta se procesa de forma segura a través de <strong>Stripe</strong>; Kasea no
            almacena los datos de la tarjeta. En los pedidos con recogida en tienda también puede
            ofrecerse el pago en efectivo en el momento de la recogida. El pedido se considera aceptado
            cuando se confirma el pago (o la reserva, en el caso del pago en efectivo).
          </p>
        </section>

        <section>
          <h2 className="mb-2 font-display text-xl text-foreground">5. Envíos y recogida</h2>
          <p>
            Los envíos se realizan a través de <strong>[EMPRESA DE ENVÍOS]</strong> a la dirección
            indicada. Los gastos y el umbral de envío gratuito se muestran en el proceso de compra. El
            plazo estimado de entrega es de <strong>[PLAZO]</strong> días hábiles. También es posible la
            recogida en tienda cuando el cliente lo selecciona.
          </p>
        </section>

        <section>
          <h2 className="mb-2 font-display text-xl text-foreground">6. Derecho de desistimiento</h2>
          <p>
            Como consumidor, dispones de 14 días naturales desde la recepción para desistir de la compra
            sin justificación, conforme a la normativa española y europea. <strong>Excepción:</strong> las
            fundas personalizadas, al fabricarse según tus especificaciones, están excluidas del derecho
            de desistimiento. Para ejercerlo, escribe a [EMAIL DE CONTACTO].
          </p>
        </section>

        <section>
          <h2 className="mb-2 font-display text-xl text-foreground">7. Devoluciones y garantía</h2>
          <p>
            Los productos cuentan con la garantía legal aplicable. Si recibes un producto defectuoso o
            erróneo, contáctanos en [EMAIL DE CONTACTO] para gestionar la sustitución o el reembolso.
          </p>
        </section>

        <section>
          <h2 className="mb-2 font-display text-xl text-foreground">8. Legislación y resolución de conflictos</h2>
          <p>
            Estas condiciones se rigen por la legislación española. Puedes acudir a la plataforma de
            resolución de litigios en línea de la UE:{" "}
            <a
              href="https://ec.europa.eu/consumers/odr"
              target="_blank"
              rel="noreferrer"
              className="underline"
            >
              ec.europa.eu/consumers/odr
            </a>
            .
          </p>
        </section>
      </div>
    </div>
  );
}
