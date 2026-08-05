import { useQuery } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { listCategoryImagesPublic } from "@/lib/admin.functions";

export type CategorySlug = "transparentes" | "sublimacion";

export function useCategoryImages() {
  const listFn = useServerFn(listCategoryImagesPublic);
  return useQuery({
    queryKey: ["public", "category-images"],
    queryFn: () => listFn(),
    staleTime: 5 * 60 * 1000,
  });
}

export function pickCategoryImage(
  data: Array<{ slug: string; image_url: string; alt: string; title: string }> | undefined,
  slug: CategorySlug,
  fallbackUrl: string,
  fallbackAlt: string,
): { url: string; alt: string } {
  const found = data?.find((c) => c.slug === slug);
  if (found && found.image_url) {
    return { url: found.image_url, alt: found.alt || fallbackAlt };
  }
  return { url: fallbackUrl, alt: fallbackAlt };
}
