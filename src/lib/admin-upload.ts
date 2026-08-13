import { supabase } from "@/integrations/supabase/client";

const BUCKET = "site-images";

// Imágenes de tienda (productos, carrusel, categorías): se guardan con URL
// PÚBLICA PERMANENTE. Requiere que el bucket `site-images` sea público en
// Supabase. Antes se usaban URLs firmadas que caducaban al año (se rompían).
export async function uploadImage(file: File, folder: "carousel" | "products" | "categories"): Promise<string> {
  const ext = file.name.split(".").pop() || "jpg";
  const path = `${folder}/${crypto.randomUUID()}.${ext}`;
  const { error } = await supabase.storage.from(BUCKET).upload(path, file, {
    cacheControl: "31536000",
    upsert: false,
    contentType: file.type,
  });
  if (error) throw new Error(error.message);
  // URL pública permanente (no caduca). El bucket debe ser público.
  const { data } = supabase.storage.from(BUCKET).getPublicUrl(path);
  return data.publicUrl;
}

export async function pickFile(): Promise<File | null> {
  return new Promise((resolve) => {
    const input = document.createElement("input");
    input.type = "file";
    input.accept = "image/*";
    input.onchange = () => {
      resolve(input.files?.[0] ?? null);
    };
    input.click();
  });
}
