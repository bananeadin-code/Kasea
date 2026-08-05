import { supabase } from "@/integrations/supabase/client";

const BUCKET = "site-images";
const SIGN_EXPIRY = 60 * 60 * 24 * 365; // 1 year

export async function uploadImage(file: File, folder: "carousel" | "products" | "categories"): Promise<string> {
  const ext = file.name.split(".").pop() || "jpg";
  const path = `${folder}/${crypto.randomUUID()}.${ext}`;
  const { error } = await supabase.storage.from(BUCKET).upload(path, file, {
    cacheControl: "31536000",
    upsert: false,
    contentType: file.type,
  });
  if (error) throw new Error(error.message);
  const { data, error: signErr } = await supabase.storage
    .from(BUCKET)
    .createSignedUrl(path, SIGN_EXPIRY);
  if (signErr || !data) throw new Error(signErr?.message ?? "Signed URL failed");
  return data.signedUrl;
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
