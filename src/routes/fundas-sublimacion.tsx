import { createFileRoute } from "@tanstack/react-router";
import { CollectionPage } from "@/components/CollectionPage";

export const Route = createFileRoute("/fundas-sublimacion")({
  head: () => ({
    meta: [
      { title: "Fundas para el móvil — Kasea Store" },
      { name: "description", content: "Fundas para el móvil: personaliza tu móvil con la imagen, foto o diseño que tú elijas. Calidad premium y colores vibrantes." },
      { property: "og:title", content: "Fundas para el móvil | Kasea Store" },
      { property: "og:description", content: "Fundas listas para personalizar con tus propios diseños." },
      { property: "og:url", content: "/fundas-sublimacion" },
    ],
    links: [{ rel: "canonical", href: "/fundas-sublimacion" }],
  }),
  component: () => (
    <CollectionPage
      collectionHandle="fundas-sublimacion"
      source="all"
      eyebrow="Colección"
      title="Fundas para el móvil"
      intro="Convierte tu funda en una pieza única. Ideales para personalizar con fotografías, ilustraciones o diseños propios."
    />
  ),
});
