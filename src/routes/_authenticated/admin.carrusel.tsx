import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { useServerFn } from "@tanstack/react-start";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Loader2, Save } from "lucide-react";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import { SortableImageGrid, type ImageItem } from "@/components/admin/SortableImageGrid";
import { listCarouselImagesPublic, saveCarouselImages } from "@/lib/admin.functions";

export const Route = createFileRoute("/_authenticated/admin/carrusel")({
  component: CarouselAdmin,
});

function CarouselAdmin() {
  const listFn = useServerFn(listCarouselImagesPublic);
  const saveFn = useServerFn(saveCarouselImages);
  const [items, setItems] = useState<ImageItem[]>([]);
  const [dirty, setDirty] = useState(false);

  const { data, isLoading } = useQuery({
    queryKey: ["admin", "carousel"],
    queryFn: () => listFn(),
  });

  useEffect(() => {
    if (data) {
      setItems(
        data.map((r) => ({
          key: r.id,
          image_url: r.image_url,
          title: r.title ?? "",
          alt: r.alt ?? "",
          description: r.description ?? "",
        })),
      );
      setDirty(false);
    }
  }, [data]);

  const mutation = useMutation({
    mutationFn: async () =>
      saveFn({
        data: {
          items: items.map((i) => ({
            image_url: i.image_url,
            alt: i.alt,
            title: i.title,
            description: i.description ?? "",
          })),
        },
      }),
    onSuccess: () => {
      toast.success("Cambios guardados");
      setDirty(false);
    },
    onError: (err: Error) => toast.error("Error al guardar", { description: err.message }),
  });

  function handleChange(next: ImageItem[]) {
    setItems(next);
    setDirty(true);
  }

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h2 className="font-display text-2xl">Carrusel de la portada</h2>
          <p className="text-sm text-muted-foreground">
            La primera imagen se muestra como principal.
          </p>
        </div>
        <Button onClick={() => mutation.mutate()} disabled={!dirty || mutation.isPending} className="gap-2">
          {mutation.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
          Guardar cambios
        </Button>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-24">
          <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
        </div>
      ) : (
        <SortableImageGrid
          items={items}
          onChange={handleChange}
          folder="carousel"
          saving={mutation.isPending}
          showDescription
        />
      )}
    </div>
  );
}
