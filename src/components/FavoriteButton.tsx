import { Heart } from "lucide-react";
import { cn } from "@/lib/utils";
import { useFavoritesStore } from "@/lib/favorites";
import type { ShopifyProduct } from "@/lib/shopify";

interface Props {
  product: ShopifyProduct;
  className?: string;
}

/** Corazón para añadir/quitar de favoritos (localStorage). */
export function FavoriteButton({ product, className }: Props) {
  const items = useFavoritesStore((s) => s.items);
  const toggle = useFavoritesStore((s) => s.toggle);
  const active = items.some((i) => i.handle === product.node.handle);

  return (
    <button
      type="button"
      onClick={(e) => {
        e.preventDefault();
        e.stopPropagation();
        toggle(product);
      }}
      aria-label={active ? "Quitar de favoritos" : "Añadir a favoritos"}
      aria-pressed={active}
      className={cn(
        "inline-flex h-9 w-9 items-center justify-center rounded-full border border-border bg-background/85 backdrop-blur-sm transition-colors hover:bg-background",
        className,
      )}
    >
      <Heart
        className={cn("h-4 w-4 transition-colors", active ? "fill-espresso text-espresso" : "text-foreground/70")}
        strokeWidth={1.5}
      />
    </button>
  );
}
