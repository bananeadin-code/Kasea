import { createFileRoute, useNavigate, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { toast } from "sonner";
import { Loader2 } from "lucide-react";

type Mode = "signin" | "signup" | "reset";

export const Route = createFileRoute("/auth")({
  // El registro NO se enseña por defecto (evita cuentas sueltas). Se llega a él
  // con ?registro=1 (enlace discreto en el footer). El acceso del admin queda
  // limpio: solo iniciar sesión + recuperar contraseña.
  validateSearch: (s: Record<string, unknown>): { registro?: string } =>
    typeof s.registro === "string" ? { registro: s.registro } : {},
  head: () => ({
    meta: [
      { title: "Acceso — Kasea Store" },
      { name: "robots", content: "noindex" },
    ],
  }),
  component: AuthPage,
});

function AuthPage() {
  const navigate = useNavigate();
  const { registro } = Route.useSearch();
  const [mode, setMode] = useState<Mode>(registro ? "signup" : "signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  // Enruta según el rol: administrador → panel; cliente → tienda.
  async function routeByRole() {
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) return;
    const { data } = await supabase
      .from("user_roles")
      .select("role")
      .eq("user_id", user.id)
      .eq("role", "admin")
      .maybeSingle();
    navigate({ to: data ? "/admin" : "/" });
  }

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (data.session) routeByRole();
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function traducirError(msg: string): string {
    const m = msg.toLowerCase();
    if (m.includes("invalid login") || m.includes("invalid credentials")) return "Email o contraseña incorrectos.";
    if (m.includes("email not confirmed")) return "Debes confirmar tu email antes de acceder. Revisa tu bandeja de entrada.";
    if (m.includes("user already registered") || m.includes("already registered")) return "Ya existe una cuenta con este email. Inicia sesión.";
    if (m.includes("password should be") || m.includes("password is too short")) return "La contraseña debe tener al menos 6 caracteres.";
    if (m.includes("unable to validate email") || m.includes("invalid email")) return "El email introducido no es válido.";
    if (m.includes("rate limit") || m.includes("too many")) return "Demasiados intentos. Inténtalo de nuevo en unos minutos.";
    if (m.includes("network")) return "Error de conexión. Comprueba tu internet e inténtalo de nuevo.";
    if (m.includes("signup") && m.includes("disabled")) return "El registro está deshabilitado en este momento.";
    if (m.includes("user not found")) return "No existe ninguna cuenta con este email.";
    return "Ha ocurrido un error. Inténtalo de nuevo.";
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      if (mode === "reset") {
        const { error } = await supabase.auth.resetPasswordForEmail(email, {
          redirectTo: window.location.origin + "/nueva-contrasena",
        });
        if (error) throw error;
        // No revelamos si el correo existe o no (buena práctica de seguridad).
        toast.success("Si hay una cuenta con ese correo, te enviamos un enlace para restablecer la contraseña.");
        setMode("signin");
      } else if (mode === "signin") {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
        toast.success("¡Bienvenido de nuevo!");
        await routeByRole();
      } else {
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: { emailRedirectTo: window.location.origin + "/auth" },
        });
        if (error) throw error;
        if (data.session) {
          toast.success("Cuenta creada. ¡Bienvenido!");
          await routeByRole();
        } else {
          toast.success("Cuenta creada. Revisa tu email para confirmarla.");
        }
      }
    } catch (err) {
      toast.error(traducirError(err instanceof Error ? err.message : ""));
    } finally {
      setLoading(false);
    }
  }

  const title = mode === "signin" ? "Iniciar sesión" : mode === "signup" ? "Crear cuenta" : "Recuperar contraseña";
  const cta = mode === "signin" ? "Entrar" : mode === "signup" ? "Crear cuenta" : "Enviar enlace";

  return (
    <div className="container-luxe flex min-h-[70vh] items-center justify-center py-16">
      <div className="w-full max-w-md rounded-lg border bg-card p-8 shadow-sm">
        <div className="mb-6 text-center">
          <p className="eyebrow mb-2">Tu cuenta</p>
          <h1 className="font-display text-3xl">{title}</h1>
          {mode === "signup" && (
            <p className="mt-2 text-xs text-muted-foreground">
              Crear una cuenta es opcional: también puedes comprar como invitado.
            </p>
          )}
          {mode === "reset" && (
            <p className="mt-2 text-xs text-muted-foreground">
              Introduce tu correo y te enviaremos un enlace para crear una nueva contraseña.
            </p>
          )}
        </div>

        <form onSubmit={handleSubmit} className="space-y-3">
          <div>
            <label className="mb-1 block text-xs font-medium">Email</label>
            <Input type="email" required value={email} onChange={(e) => setEmail(e.target.value)} />
          </div>
          {mode !== "reset" && (
            <div>
              <label className="mb-1 block text-xs font-medium">Contraseña</label>
              <Input
                type="password"
                required
                minLength={6}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
          )}
          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : cta}
          </Button>
        </form>

        {/* Enlaces contextuales según el modo */}
        {mode === "signin" && (
          <p className="mt-4 text-center text-xs text-muted-foreground">
            <button type="button" className="underline" onClick={() => setMode("reset")}>
              ¿Olvidaste tu contraseña?
            </button>
          </p>
        )}
        {mode === "signup" && (
          <p className="mt-4 text-center text-xs text-muted-foreground">
            ¿Ya tienes cuenta?{" "}
            <button type="button" className="underline" onClick={() => setMode("signin")}>
              Iniciar sesión
            </button>
          </p>
        )}
        {mode === "reset" && (
          <p className="mt-4 text-center text-xs text-muted-foreground">
            <button type="button" className="underline" onClick={() => setMode("signin")}>
              Volver a iniciar sesión
            </button>
          </p>
        )}

        <p className="mt-6 text-center text-xs text-muted-foreground">
          <Link to="/" className="underline">Volver a la tienda</Link>
        </p>
      </div>
    </div>
  );
}
