import { createFileRoute } from "@tanstack/react-router";
import { Mail, Phone, MessageCircle, MapPin } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";

// Datos de contacto de la tienda.
const WHATSAPP_NUMBER = "34711278306"; // sin + ni espacios, para wa.me / tel
const PHONE_DISPLAY = "+34 711 278 306";
const EMAIL = "kasea.store26@gmail.com";

export const Route = createFileRoute("/contacto")({
  head: () => ({
    meta: [
      { title: "Contacto — Kasea Store" },
      { name: "description", content: "Contacta con Kasea Store por WhatsApp, correo o teléfono. Atención al cliente en español." },
      { property: "og:title", content: "Contacto — Kasea Store" },
      { property: "og:description", content: "Estamos aquí para ayudarte." },
      { property: "og:url", content: "/contacto" },
    ],
    links: [{ rel: "canonical", href: "/contacto" }],
  }),
  component: ContactPage,
});

function ContactPage() {
  // El formulario compone un mensaje y abre WhatsApp (no hay backend de correo).
  const onSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const nombre = String(fd.get("nombre") || "").trim();
    const email = String(fd.get("email") || "").trim();
    const asunto = String(fd.get("asunto") || "").trim();
    const mensaje = String(fd.get("mensaje") || "").trim();
    const text =
      `Hola Kasea, soy ${nombre}${email ? ` (${email})` : ""}.\n` +
      (asunto ? `Asunto: ${asunto}\n` : "") +
      mensaje;
    window.open(`https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent(text)}`, "_blank");
  };

  return (
    <div className="container-luxe py-16 md:py-24">
      <header className="mx-auto mb-16 max-w-2xl text-center">
        <p className="eyebrow mb-3">Hablemos</p>
        <h1 className="font-display text-5xl md:text-6xl">Estamos aquí para ti</h1>
        <p className="mt-4 text-muted-foreground">
          Escríbenos por WhatsApp, correo o teléfono. Respondemos en menos de 24 horas laborables.
        </p>
      </header>

      <div className="grid gap-12 md:grid-cols-2">
        {/* Formulario → WhatsApp */}
        <div>
          <h2 className="mb-6 font-display text-3xl">Escríbenos</h2>
          <form onSubmit={onSubmit} className="space-y-4">
            <div className="grid gap-4 sm:grid-cols-2">
              <Input name="nombre" required placeholder="Nombre" className="h-12 rounded-none" maxLength={80} />
              <Input name="email" type="email" placeholder="Email (opcional)" className="h-12 rounded-none" maxLength={120} />
            </div>
            <Input name="asunto" placeholder="Asunto" className="h-12 rounded-none" maxLength={120} />
            <Textarea name="mensaje" required placeholder="Tu mensaje" rows={6} className="resize-none rounded-none" maxLength={1000} />
            <Button
              type="submit"
              className="h-12 w-full gap-2 rounded-none bg-espresso text-xs uppercase tracking-[0.2em] text-ivory hover:bg-espresso/90"
            >
              <MessageCircle className="h-4 w-4" strokeWidth={1.5} /> Enviar por WhatsApp
            </Button>
            <p className="text-center text-xs text-muted-foreground">
              Se abrirá WhatsApp con tu mensaje listo para enviar.
            </p>
          </form>
        </div>

        {/* Medios de contacto */}
        <div className="bg-sand/40 p-8 md:p-10">
          <h2 className="mb-6 font-display text-3xl">Contacto directo</h2>

          <a
            href={`https://wa.me/${WHATSAPP_NUMBER}`}
            target="_blank"
            rel="noreferrer"
            className="mb-6 inline-flex h-12 w-full items-center justify-center gap-2 rounded-md bg-[#25D366] px-6 text-sm font-medium text-white transition-opacity hover:opacity-90"
          >
            <MessageCircle className="h-5 w-5" strokeWidth={1.75} /> Escribir por WhatsApp
          </a>

          <ul className="space-y-6">
            <li className="flex gap-4">
              <MessageCircle className="mt-1 h-5 w-5 text-gold" strokeWidth={1.5} />
              <div>
                <p className="eyebrow">WhatsApp</p>
                <a href={`https://wa.me/${WHATSAPP_NUMBER}`} target="_blank" rel="noreferrer" className="hover:text-gold">
                  {PHONE_DISPLAY}
                </a>
              </div>
            </li>
            <li className="flex gap-4">
              <Phone className="mt-1 h-5 w-5 text-gold" strokeWidth={1.5} />
              <div>
                <p className="eyebrow">Teléfono</p>
                <a href={`tel:+${WHATSAPP_NUMBER}`} className="hover:text-gold">
                  {PHONE_DISPLAY}
                </a>
              </div>
            </li>
            <li className="flex gap-4">
              <Mail className="mt-1 h-5 w-5 text-gold" strokeWidth={1.5} />
              <div>
                <p className="eyebrow">Correo</p>
                <a href={`mailto:${EMAIL}`} className="hover:text-gold">
                  {EMAIL}
                </a>
              </div>
            </li>
            <li className="flex gap-4">
              <MapPin className="mt-1 h-5 w-5 text-gold" strokeWidth={1.5} />
              <div>
                <p className="eyebrow">Recogida en tienda</p>
                <p>
                  Kasea Store
                  <br />
                  Calle Mendizábal 91 · Burjassot 46100, Valencia
                </p>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </div>
  );
}
