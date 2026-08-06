import { createFileRoute, useNavigate, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { toast } from "sonner";
import { Loader2 } from "lucide-react";

// Página a la que Supabase redirige desde el correo de "restablecer contraseña".
// El cliente de Supabase (detectSessionInUrl) crea una sesión de recuperación al
// abrir el enlace; aquí el usuario define su nueva contraseña.
export const Route = createFileRoute("/nueva-contrasena")({
  head: () => ({
    meta: [
      { title: "Nueva contraseña — Kasea Store" },
      { name: "robots", content: "noindex" },
    ],
  }),
  component: NuevaContrasenaPage,
});

function NuevaContrasenaPage() {
  const navigate = useNavigate();
  const [ready, setReady] = useState<boolean | null>(null); // null = comprobando
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // La sesión de recuperación puede estar ya lista o llegar por el evento.
    supabase.auth.getSession().then(({ data }) => {
      if (data.session) setReady(true);
      else setReady((r) => (r === null ? false : r));
    });
    const { data: sub } = supabase.auth.onAuthStateChange((event, session) => {
      if (event === "PASSWORD_RECOVERY" || session) setReady(true);
    });
    return () => sub.subscription.unsubscribe();
  }, []);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (password.length < 6) {
      toast.error("La contraseña debe tener al menos 6 caracteres.");
      return;
    }
    if (password !== confirm) {
      toast.error("Las contraseñas no coinciden.");
      return;
    }
    setLoading(true);
    try {
      const { error } = await supabase.auth.updateUser({ password });
      if (error) throw error;
      toast.success("Contraseña actualizada. Iniciando sesión…");
      // Tras actualizar queda con sesión iniciada: enrutamos según el rol.
      const {
        data: { user },
      } = await supabase.auth.getUser();
      let isAdmin = false;
      if (user) {
        const { data } = await supabase
          .from("user_roles")
          .select("role")
          .eq("user_id", user.id)
          .eq("role", "admin")
          .maybeSingle();
        isAdmin = !!data;
      }
      navigate({ to: isAdmin ? "/admin" : "/" });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "No se pudo actualizar la contraseña.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="container-luxe flex min-h-[70vh] items-center justify-center py-16">
      <div className="w-full max-w-md rounded-lg border bg-card p-8 shadow-sm">
        <div className="mb-6 text-center">
          <p className="eyebrow mb-2">Tu cuenta</p>
          <h1 className="font-display text-3xl">Nueva contraseña</h1>
        </div>

        {ready === null ? (
          <div className="flex justify-center py-8">
            <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
          </div>
        ) : ready === false ? (
          <div className="text-center text-sm text-muted-foreground">
            <p>Este enlace no es válido o ha caducado.</p>
            <p className="mt-4">
              <Link to="/auth" search={{ registro: undefined }} className="underline">
                Solicitar un nuevo enlace
              </Link>
            </p>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-3">
            <div>
              <label className="mb-1 block text-xs font-medium">Nueva contraseña</label>
              <Input
                type="password"
                required
                minLength={6}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
            <div>
              <label className="mb-1 block text-xs font-medium">Repite la contraseña</label>
              <Input
                type="password"
                required
                minLength={6}
                value={confirm}
                onChange={(e) => setConfirm(e.target.value)}
              />
            </div>
            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : "Guardar contraseña"}
            </Button>
          </form>
        )}
      </div>
    </div>
  );
}
