import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Loader2, Mail, KeyRound } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { supabase } from "@/integrations/supabase/client";

export const Route = createFileRoute("/_authenticated/admin/cuenta")({
  component: AdminCuenta,
});

function AdminCuenta() {
  const [currentEmail, setCurrentEmail] = useState("");
  const [email, setEmail] = useState("");
  const [savingEmail, setSavingEmail] = useState(false);

  const [password, setPassword] = useState("");
  const [password2, setPassword2] = useState("");
  const [savingPass, setSavingPass] = useState(false);

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => {
      const e = data.user?.email ?? "";
      setCurrentEmail(e);
      setEmail(e);
    });
  }, []);

  async function changeEmail(e: React.FormEvent) {
    e.preventDefault();
    if (!email.trim() || email.trim() === currentEmail) return;
    setSavingEmail(true);
    try {
      const { error } = await supabase.auth.updateUser({ email: email.trim() });
      if (error) throw error;
      toast.success("Revisa tu correo", {
        description: "Te enviamos un enlace para confirmar el cambio de email.",
      });
    } catch (err) {
      toast.error("No se pudo cambiar el correo", {
        description: err instanceof Error ? err.message : undefined,
      });
    } finally {
      setSavingEmail(false);
    }
  }

  async function changePassword(e: React.FormEvent) {
    e.preventDefault();
    if (password.length < 6) {
      toast.error("La contraseña debe tener al menos 6 caracteres.");
      return;
    }
    if (password !== password2) {
      toast.error("Las contraseñas no coinciden.");
      return;
    }
    setSavingPass(true);
    try {
      const { error } = await supabase.auth.updateUser({ password });
      if (error) throw error;
      toast.success("Contraseña actualizada");
      setPassword("");
      setPassword2("");
    } catch (err) {
      toast.error("No se pudo cambiar la contraseña", {
        description: err instanceof Error ? err.message : undefined,
      });
    } finally {
      setSavingPass(false);
    }
  }

  return (
    <div className="max-w-lg">
      <div className="mb-6">
        <h2 className="font-display text-2xl">Mi cuenta</h2>
        <p className="text-sm text-muted-foreground">Cambia tu correo de acceso o tu contraseña.</p>
      </div>

      <div className="space-y-6">
        {/* Email */}
        <form onSubmit={changeEmail} className="rounded-lg border bg-card p-6">
          <div className="mb-4 flex items-center gap-2 text-sm font-medium">
            <Mail className="h-4 w-4" /> Correo de acceso
          </div>
          <Label htmlFor="email">Email</Label>
          <Input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <p className="mt-1 text-xs text-muted-foreground">
            Al cambiarlo, recibirás un enlace de confirmación en el correo nuevo.
          </p>
          <div className="mt-4">
            <Button type="submit" disabled={savingEmail || email.trim() === currentEmail} className="gap-2">
              {savingEmail && <Loader2 className="h-4 w-4 animate-spin" />} Guardar correo
            </Button>
          </div>
        </form>

        {/* Password */}
        <form onSubmit={changePassword} className="rounded-lg border bg-card p-6">
          <div className="mb-4 flex items-center gap-2 text-sm font-medium">
            <KeyRound className="h-4 w-4" /> Contraseña
          </div>
          <div className="space-y-3">
            <div>
              <Label htmlFor="pass">Nueva contraseña</Label>
              <Input
                id="pass"
                type="password"
                minLength={6}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="new-password"
              />
            </div>
            <div>
              <Label htmlFor="pass2">Repite la contraseña</Label>
              <Input
                id="pass2"
                type="password"
                minLength={6}
                value={password2}
                onChange={(e) => setPassword2(e.target.value)}
                autoComplete="new-password"
              />
            </div>
          </div>
          <div className="mt-4">
            <Button type="submit" disabled={savingPass} className="gap-2">
              {savingPass && <Loader2 className="h-4 w-4 animate-spin" />} Cambiar contraseña
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
