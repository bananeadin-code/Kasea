import { Link } from "@tanstack/react-router";
import { BrandLogo } from "./BrandLogo";

const COLS = [
  {
    title: "Tienda",
    links: [
      { to: "/tienda", label: "Todos los productos" },
      
    ],
  },
  {
    title: "Ayuda",
    links: [
      { to: "/contacto", label: "Contacto" },
      { to: "/personalizar", label: "Personaliza tu funda" },
    ],
  },
  {
    title: "Marca",
    links: [
      { to: "/", label: "Inicio" },
      { to: "/tienda", label: "Colección" },
      { to: "/contacto", label: "Atención al cliente" },
    ],
  },
];

export function SiteFooter() {
  return (
    <footer className="mt-24 border-t border-border/60 bg-sand/22">
      <div className="container-luxe grid grid-cols-1 gap-10 py-16 md:grid-cols-12 md:py-20">
        <div className="md:col-span-6">
          <BrandLogo className="inline-flex" imageClassName="h-18 w-auto max-w-[13rem] object-contain md:h-22 md:max-w-[16rem]" />
          <p className="mt-5 max-w-sm text-sm leading-relaxed text-muted-foreground">
            Fundas con una imagen más editorial, una presencia más cuidada y una experiencia digital construida para reforzar el valor percibido de Kasea Store. Y si no encuentras el diseño que te identifique, podemos crear una funda personalizada hecha solo para ti.
          </p>
        </div>

        {COLS.map((col) => (
          <div key={col.title} className="md:col-span-2">
            <h4 className="eyebrow mb-4">{col.title}</h4>
            <ul className="space-y-2.5">
              {col.links.map((link) => (
                <li key={link.label}>
                  <Link to={link.to} className="text-sm text-foreground/78 transition-colors hover:text-foreground">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>
      <div className="border-t border-border/60">
        <div className="container-luxe flex flex-col items-center justify-between gap-3 py-6 text-xs text-muted-foreground md:flex-row">
          <p>© {new Date().getFullYear()} Kasea Store. Todos los derechos reservados.</p>
          <p className="flex items-center gap-3">
            <span>Fundas premium para iPhone · Hecho en España</span>
            <Link to="/admin" className="opacity-50 hover:opacity-100 hover:text-foreground">Admin</Link>
          </p>
        </div>
      </div>
    </footer>
  );
}
