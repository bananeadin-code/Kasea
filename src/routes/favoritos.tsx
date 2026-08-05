import { createFileRoute, Link } from "@tanstack/react-router";
import { Heart, X } from "lucide-react";
import { useFavoritesStore } from "@/lib/favorites";
import { formatPrice } from "@/lib/shopify";

export const Route = createFileRoute("/favoritos")({
  head: () => ({
    meta: [
      { title: "Tus favoritos — Kasea Store" },
      { name: "robots", content: "noindex" },
    ],
  }),
  component: FavoritesPage,
});

function FavoritesPage() {
  const items = useFavoritesStore((s) => s.items);
  const remove = useFavoritesStore((s) => s.remove);

  return (
    <div className="container-luxe py-16 md:py-24">
      <header className="mx-auto mb-12 max-w-2xl text-center">
        <p className="eyebrow mb-3">Tu selección</p>
        <h1 className="font-display text-5xl md:text-6xl">Favoritos</h1>
        <p className="mt-4 text-muted-foreground">Guarda tus fundas preferidas para encontrarlas fácil.</p>
      </header>

      {items.length === 0 ? (
        <div className="mx-auto max-w-md rounded-xl border border-dashed border-border bg-sand/20 py-20 text-center">
          <Heart className="mx-auto h-10 w-10 text-muted-foreground" strokeWidth={1} />
          <p className="mt-4 text-sm text-muted-foreground">
            Aún no tienes favoritos. Pulsa el corazón en cualquier producto para guardarlo.
          </p>
          <Link
            to="/tienda"
            className="mt-6 inline-flex h-11 items-center gap-2 rounded-md bg-espresso px-6 text-sm font-medium uppercase tracking-[0.14em] text-ivory"
          >
            Ver la tienda
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-6 md:grid-cols-3 lg:grid-cols-4 md:gap-8">
          {items.map((item) => (
            <div key={item.handle} className="group flex flex-col">
              <div className="relative mb-4 aspect-[4/5] overflow-hidden rounded-xl bg-white">
                <Link to="/product/$handle" params={{ handle: item.handle }} className="block h-full w-full">
                  {item.imageUrl ? (
                    <img
                      src={item.imageUrl}
                      alt={item.title}
                      loading="lazy"
                      className="absolute inset-0 h-full w-full object-contain p-3 md:p-5"
                    />
                  ) : (
                    <div className="absolute inset-0 bg-gradient-to-br from-sand/50 to-accent/40" />
                  )}
                </Link>
                <button
                  type="button"
                  onClick={() => remove(item.handle)}
                  aria-label="Quitar de favoritos"
                  className="absolute right-2 top-2 inline-flex h-9 w-9 items-center justify-center rounded-full border border-border bg-background/85 backdrop-blur-sm transition-colors hover:bg-background"
                >
                  <X className="h-4 w-4" strokeWidth={1.5} />
                </button>
              </div>
              <div className="flex items-baseline justify-between gap-3">
                <Link to="/product/$handle" params={{ handle: item.handle }} className="font-display text-lg leading-tight hover:underline">
                  {item.title}
                </Link>
                <span className="text-sm tabular-nums text-foreground/80">
                  {formatPrice(item.priceAmount, item.currencyCode)}
                </span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
