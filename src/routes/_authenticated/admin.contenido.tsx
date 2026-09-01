import { createFileRoute } from "@tanstack/react-router";
import { useServerFn } from "@tanstack/react-start";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { Loader2, Type } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { getSiteContentAdmin, updateSiteContent } from "@/lib/admin-catalog.functions";
import { SITE_CONTENT_FIELDS, SITE_CONTENT_DEFAULTS } from "@/lib/site-content";

export const Route = createFileRoute("/_authenticated/admin/contenido")({
  component: AdminContenido,
});

function AdminContenido() {
  const qc = useQueryClient();
  const getFn = useServerFn(getSiteContentAdmin);
  const saveFn = useServerFn(updateSiteContent);

  const { data, isLoading } = useQuery({
    queryKey: ["admin-content"],
    queryFn: () => getFn(),
  });

  const [values, setValues] = useState<Record<string, string>>({});
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (data) {
      const merged: Record<string, string> = {};
      for (const f of SITE_CONTENT_FIELDS) {
        merged[f.key] = data[f.key] ?? SITE_CONTENT_DEFAULTS[f.key] ?? "";
      }
      setValues(merged);
    }
  }, [data]);

  async function save() {
    setSaving(true);
    try {
      const entries = SITE_CONTENT_FIELDS.map((f) => ({ key: f.key, value: values[f.key] ?? "" }));
      await saveFn({ data: { entries } });
      await qc.invalidateQueries({ queryKey: ["admin-content"] });
      await qc.invalidateQueries({ queryKey: ["site-content"] });
      toast.success("Textos guardados");
    } catch (e) {
      toast.error("No se pudo guardar", { description: e instanceof Error ? e.message : undefined });
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="max-w-2xl">
      <div className="mb-6">
        <h2 className="font-display text-2xl">Textos de la web</h2>
        <p className="text-sm text-muted-foreground">
          Cambia los textos destacados de la portada y la cinta de anuncio (ideal para temporadas o
          campañas) y los <strong>datos legales</strong> (Términos y Política de Privacidad). Los cambios
          se aplican en la web al guardar; la fecha de "última actualización" de las páginas legales se
          pone sola.
        </p>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-16">
          <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
        </div>
      ) : (
        <div className="space-y-4 rounded-lg border bg-card p-6">
          <div className="mb-2 flex items-center gap-2 text-sm text-muted-foreground">
            <Type className="h-4 w-4" /> Estos textos se muestran en la portada de la tienda.
          </div>
          {SITE_CONTENT_FIELDS.map((f) => (
            <div key={f.key}>
              <Label htmlFor={f.key}>{f.label}</Label>
              {f.multiline ? (
                <textarea
                  id={f.key}
                  rows={3}
                  className="mt-1 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  value={values[f.key] ?? ""}
                  onChange={(e) => setValues((v) => ({ ...v, [f.key]: e.target.value }))}
                />
              ) : (
                <Input
                  id={f.key}
                  value={values[f.key] ?? ""}
                  onChange={(e) => setValues((v) => ({ ...v, [f.key]: e.target.value }))}
                />
              )}
              {f.help && <p className="mt-1 text-xs text-muted-foreground">{f.help}</p>}
            </div>
          ))}
          <div className="pt-2">
            <Button onClick={save} disabled={saving} className="gap-2">
              {saving && <Loader2 className="h-4 w-4 animate-spin" />} Guardar cambios
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
