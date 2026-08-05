export interface DesignRenderOptions {
  specW: number;
  specH: number;
  image: string | null;
  fit: "cover" | "contain";
  zoom: number;
  imgX: number;
  imgY: number;
  rotation: number;
  text: string;
  font: string;
  color: string;
  fontSize: number; // px en la vista previa
  previewWidth: number; // ancho real de la vista previa en px
  posX: number;
  posY: number;
  textW: number;
  textRot: number;
}

function loadImage(src: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = () => reject(new Error("No se pudo cargar la imagen"));
    img.src = src;
  });
}

function wrapLines(
  ctx: CanvasRenderingContext2D,
  text: string,
  maxWidth: number,
): string[] {
  const lines: string[] = [];
  for (const paragraph of text.split("\n")) {
    let current = "";
    for (const word of paragraph.split(" ")) {
      const candidate = current ? `${current} ${word}` : word;
      if (ctx.measureText(candidate).width > maxWidth && current) {
        lines.push(current);
        current = word;
      } else {
        current = candidate;
      }
    }
    lines.push(current);
  }
  return lines;
}

/** Renderiza el diseño de la funda a un data URL PNG. */
export async function renderDesign(o: DesignRenderOptions): Promise<string> {
  const W = 1200;
  const H = Math.round((W * o.specH) / o.specW);
  const canvas = document.createElement("canvas");
  canvas.width = W;
  canvas.height = H;
  const ctx = canvas.getContext("2d");
  if (!ctx) throw new Error("Canvas no disponible");

  ctx.fillStyle = "#ffffff";
  ctx.fillRect(0, 0, W, H);

  if (o.image) {
    const img = await loadImage(o.image);
    const scaleBase =
      o.fit === "cover"
        ? Math.max(W / img.width, H / img.height)
        : Math.min(W / img.width, H / img.height);
    const dw = img.width * scaleBase;
    const dh = img.height * scaleBase;
    const dx = (W - dw) * (o.imgX / 100);
    const dy = (H - dh) * (o.imgY / 100);

    ctx.save();
    ctx.beginPath();
    ctx.rect(0, 0, W, H);
    ctx.clip();
    ctx.translate(W / 2, H / 2);
    ctx.rotate((o.rotation * Math.PI) / 180);
    ctx.scale(o.zoom, o.zoom);
    ctx.translate(-W / 2, -H / 2);
    ctx.drawImage(img, dx, dy, dw, dh);
    ctx.restore();
  }

  if (o.text.trim()) {
    const k = W / Math.max(1, o.previewWidth);
    const fontSize = o.fontSize * k;
    ctx.save();
    ctx.font = `${fontSize}px ${o.font}`;
    ctx.fillStyle = o.color;
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";

    const maxWidth = (o.textW / 100) * W;
    const lines = wrapLines(ctx, o.text, maxWidth);
    const lineHeight = fontSize * 1.1;

    ctx.translate((o.posX / 100) * W, (o.posY / 100) * H);
    ctx.rotate((o.textRot * Math.PI) / 180);
    const startY = -((lines.length - 1) * lineHeight) / 2;
    lines.forEach((line, i) => ctx.fillText(line, 0, startY + i * lineHeight));
    ctx.restore();
  }

  return canvas.toDataURL("image/png");
}
