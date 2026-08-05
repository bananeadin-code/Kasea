import { useState } from "react";
import {
  DndContext,
  closestCenter,
  PointerSensor,
  KeyboardSensor,
  useSensor,
  useSensors,
  type DragEndEvent,
} from "@dnd-kit/core";
import {
  SortableContext,
  arrayMove,
  rectSortingStrategy,
  sortableKeyboardCoordinates,
  useSortable,
} from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";
import { GripVertical, Star, Trash2, RefreshCw, Pencil, Plus, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { pickFile, uploadImage } from "@/lib/admin-upload";
import { toast } from "sonner";

export type ImageItem = {
  key: string; // stable local key
  image_url: string;
  title: string;
  alt: string;
  description?: string;
  is_uploaded?: boolean;
};

type Props = {
  items: ImageItem[];
  onChange: (next: ImageItem[]) => void;
  folder: "carousel" | "products";
  saving?: boolean;
  showDescription?: boolean;
};

export function SortableImageGrid({ items, onChange, folder, saving, showDescription }: Props) {
  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 5 } }),
    useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates }),
  );
  const [uploading, setUploading] = useState(false);
  const [editing, setEditing] = useState<ImageItem | null>(null);
  const [deleting, setDeleting] = useState<ImageItem | null>(null);

  function handleDragEnd(e: DragEndEvent) {
    const { active, over } = e;
    if (!over || active.id === over.id) return;
    const oldIndex = items.findIndex((i) => i.key === active.id);
    const newIndex = items.findIndex((i) => i.key === over.id);
    if (oldIndex < 0 || newIndex < 0) return;
    onChange(arrayMove(items, oldIndex, newIndex));
  }

  async function handleAdd() {
    const file = await pickFile();
    if (!file) return;
    setUploading(true);
    try {
      const url = await uploadImage(file, folder);
      onChange([
        ...items,
        { key: crypto.randomUUID(), image_url: url, title: "", alt: "", description: "", is_uploaded: true },
      ]);
      toast.success("Imagen añadida");
    } catch (err) {
      toast.error("No se pudo subir", { description: err instanceof Error ? err.message : "" });
    } finally {
      setUploading(false);
    }
  }

  async function handleReplace(item: ImageItem) {
    const file = await pickFile();
    if (!file) return;
    setUploading(true);
    try {
      const url = await uploadImage(file, folder);
      onChange(items.map((i) => (i.key === item.key ? { ...i, image_url: url, is_uploaded: true } : i)));
      toast.success("Imagen reemplazada");
    } catch (err) {
      toast.error("No se pudo reemplazar", { description: err instanceof Error ? err.message : "" });
    } finally {
      setUploading(false);
    }
  }

  function handleMakePrimary(item: ImageItem) {
    const idx = items.findIndex((i) => i.key === item.key);
    if (idx <= 0) return;
    const copy = [...items];
    copy.splice(idx, 1);
    copy.unshift(item);
    onChange(copy);
    toast.success("Marcada como principal");
  }

  function handleDelete(item: ImageItem) {
    onChange(items.filter((i) => i.key !== item.key));
    setDeleting(null);
    toast.success("Imagen eliminada");
  }

  function handleSaveEdit(next: ImageItem) {
    onChange(items.map((i) => (i.key === next.key ? next : i)));
    setEditing(null);
    toast.success("Cambios guardados");
  }

  return (
    <>
      <div className="mb-4 flex items-center justify-between gap-3">
        <p className="text-xs text-muted-foreground">
          {items.length} imagen{items.length === 1 ? "" : "es"} · Arrastra para reordenar. La primera es la principal.
        </p>
        <Button onClick={handleAdd} disabled={uploading || saving} size="sm" className="gap-2">
          {uploading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
          Añadir imagen
        </Button>
      </div>

      <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
        <SortableContext items={items.map((i) => i.key)} strategy={rectSortingStrategy}>
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
            {items.map((item, idx) => (
              <SortableCard
                key={item.key}
                item={item}
                isPrimary={idx === 0}
                onEdit={() => setEditing(item)}
                onReplace={() => handleReplace(item)}
                onDelete={() => setDeleting(item)}
                onMakePrimary={() => handleMakePrimary(item)}
              />
            ))}
          </div>
        </SortableContext>
      </DndContext>

      <Dialog open={!!editing} onOpenChange={(o) => !o && setEditing(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Editar imagen</DialogTitle>
          </DialogHeader>
          {editing && (
            <EditForm
              key={editing.key}
              item={editing}
              showDescription={showDescription}
              onCancel={() => setEditing(null)}
              onSave={handleSaveEdit}
            />
          )}
        </DialogContent>
      </Dialog>

      <AlertDialog open={!!deleting} onOpenChange={(o) => !o && setDeleting(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>¿Eliminar esta imagen?</AlertDialogTitle>
            <AlertDialogDescription>
              La imagen desaparecerá del listado. Esta acción se aplicará al guardar.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancelar</AlertDialogCancel>
            <AlertDialogAction onClick={() => deleting && handleDelete(deleting)}>
              Eliminar
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}

function SortableCard({
  item,
  isPrimary,
  onEdit,
  onReplace,
  onDelete,
  onMakePrimary,
}: {
  item: ImageItem;
  isPrimary: boolean;
  onEdit: () => void;
  onReplace: () => void;
  onDelete: () => void;
  onMakePrimary: () => void;
}) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({
    id: item.key,
  });
  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
    zIndex: isDragging ? 10 : undefined,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={`group relative overflow-hidden rounded-lg border bg-card transition-shadow ${
        isDragging ? "shadow-2xl ring-2 ring-primary" : "shadow-sm hover:shadow-md"
      }`}
    >
      {isPrimary && (
        <div className="absolute left-2 top-2 z-10 inline-flex items-center gap-1 rounded-full bg-primary px-2.5 py-1 text-xs font-medium text-primary-foreground shadow">
          <Star className="h-3 w-3 fill-current" /> Principal
        </div>
      )}
      <button
        {...attributes}
        {...listeners}
        aria-label="Arrastrar"
        className="absolute right-2 top-2 z-10 cursor-grab rounded-md bg-background/90 p-1.5 opacity-0 shadow transition-opacity group-hover:opacity-100 active:cursor-grabbing"
      >
        <GripVertical className="h-4 w-4" />
      </button>
      <div className="aspect-square overflow-hidden bg-secondary">
        {item.image_url ? (
          <img src={item.image_url} alt={item.alt} className="h-full w-full object-cover" />
        ) : (
          <div className="flex h-full w-full items-center justify-center text-xs text-muted-foreground">
            Sin imagen
          </div>
        )}
      </div>
      <div className="p-3">
        <p className="truncate text-sm font-medium">{item.title || "(sin título)"}</p>
        <p className="truncate text-xs text-muted-foreground">{item.alt || "—"}</p>
        <div className="mt-3 grid grid-cols-4 gap-1">
          <button
            onClick={onEdit}
            className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            title="Editar"
          >
            <Pencil className="mx-auto h-4 w-4" />
          </button>
          <button
            onClick={onReplace}
            className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground"
            title="Reemplazar"
          >
            <RefreshCw className="mx-auto h-4 w-4" />
          </button>
          <button
            onClick={onMakePrimary}
            disabled={isPrimary}
            className="rounded p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground disabled:opacity-30"
            title="Marcar como principal"
          >
            <Star className="mx-auto h-4 w-4" />
          </button>
          <button
            onClick={onDelete}
            className="rounded p-1.5 text-destructive hover:bg-destructive/10"
            title="Eliminar"
          >
            <Trash2 className="mx-auto h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
}

function EditForm({
  item,
  showDescription,
  onCancel,
  onSave,
}: {
  item: ImageItem;
  showDescription?: boolean;
  onCancel: () => void;
  onSave: (next: ImageItem) => void;
}) {
  const [title, setTitle] = useState(item.title);
  const [alt, setAlt] = useState(item.alt);
  const [description, setDescription] = useState(item.description ?? "");
  return (
    <div className="space-y-4">
      <div>
        <label className="mb-1 block text-xs font-medium">Título</label>
        <Input value={title} onChange={(e) => setTitle(e.target.value)} />
      </div>
      <div>
        <label className="mb-1 block text-xs font-medium">Texto alternativo (accesibilidad / SEO)</label>
        <Input value={alt} onChange={(e) => setAlt(e.target.value)} />
      </div>
      {showDescription && (
        <div>
          <label className="mb-1 block text-xs font-medium">Descripción</label>
          <Textarea value={description} onChange={(e) => setDescription(e.target.value)} rows={3} />
        </div>
      )}
      <DialogFooter>
        <Button variant="outline" onClick={onCancel}>
          Cancelar
        </Button>
        <Button onClick={() => onSave({ ...item, title, alt, description })}>Guardar</Button>
      </DialogFooter>
    </div>
  );
}
