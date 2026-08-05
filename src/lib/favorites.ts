// ============================================================================
// Favoritos — 100% en el cliente (localStorage), sin cuentas ni registro.
// ============================================================================
import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";
import type { ShopifyProduct } from "./shopify";

export interface FavoriteItem {
  handle: string;
  title: string;
  imageUrl: string;
  priceAmount: string;
  currencyCode: string;
}

interface FavoritesStore {
  items: FavoriteItem[];
  toggle: (product: ShopifyProduct) => void;
  remove: (handle: string) => void;
  clear: () => void;
}

export const useFavoritesStore = create<FavoritesStore>()(
  persist(
    (set, get) => ({
      items: [],
      toggle: (product) => {
        const n = product.node;
        const exists = get().items.some((i) => i.handle === n.handle);
        if (exists) {
          set({ items: get().items.filter((i) => i.handle !== n.handle) });
        } else {
          set({
            items: [
              ...get().items,
              {
                handle: n.handle,
                title: n.title,
                imageUrl: n.images.edges[0]?.node.url ?? "",
                priceAmount: n.priceRange.minVariantPrice.amount,
                currencyCode: n.priceRange.minVariantPrice.currencyCode,
              },
            ],
          });
        }
      },
      remove: (handle) => set({ items: get().items.filter((i) => i.handle !== handle) }),
      clear: () => set({ items: [] }),
    }),
    {
      name: "kasea-favorites",
      storage: createJSONStorage(() => localStorage),
      partialize: (s) => ({ items: s.items }),
    },
  ),
);
