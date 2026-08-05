// ============================================================================
// Seed: importa el catálogo actual de Shopify -> Supabase.
//
// Uso (una sola vez, en local):
//   1) Ten en tu .env (no versionado):
//        SUPABASE_URL=...
//        SUPABASE_SERVICE_ROLE_KEY=...   (Supabase > Settings > API > service_role)
//   2) Ejecuta:
//        node scripts/seed-from-shopify.mjs
//
// Es IDEMPOTENTE: puedes re-ejecutarlo; hace upsert por handle y reemplaza
// variantes/imágenes/colecciones de cada producto sin duplicar.
//
// Nota sobre el STOCK: el token Storefront de Shopify NO expone las cantidades
// reales de inventario (le falta el scope de inventario). Por eso este seed
// asigna un stock por defecto (SEED_DEFAULT_STOCK, 25) a cada variante; el
// dueño ajustará las cantidades reales desde el panel de admin (Fase 5).
// ============================================================================
import { readFileSync, existsSync } from "node:fs";
import { createClient } from "@supabase/supabase-js";

// --- Carga simple de .env (sin dependencias) ---
if (existsSync(".env")) {
  for (const line of readFileSync(".env", "utf8").split("\n")) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
    if (m && !process.env[m[1]]) {
      process.env[m[1]] = m[2].replace(/^["']|["']$/g, "");
    }
  }
}

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const DEFAULT_STOCK = Number(process.env.SEED_DEFAULT_STOCK ?? 25);

// Origen Shopify (LEGADO — el catálogo ya se siembra por migración SQL; este
// script solo sirve si quisieras re-importar desde Shopify). El token va por
// variable de entorno, nunca escrito en el código.
const SHOPIFY_URL =
  process.env.SHOPIFY_STOREFRONT_URL ||
  "https://kasea-luxe-build-6s3dp.myshopify.com/api/2025-07/graphql.json";
const SHOPIFY_TOKEN = process.env.SHOPIFY_STOREFRONT_TOKEN || "";
if (!SHOPIFY_TOKEN) {
  console.error("Falta SHOPIFY_STOREFRONT_TOKEN en el entorno (script legado).");
  process.exit(1);
}

if (!SUPABASE_URL || !SERVICE_KEY) {
  console.error("❌ Faltan SUPABASE_URL y/o SUPABASE_SERVICE_ROLE_KEY en el entorno (.env).");
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SERVICE_KEY, {
  auth: { persistSession: false, autoRefreshToken: false },
});

const PRODUCTS_QUERY = `
  query GetProducts($first: Int!, $after: String) {
    products(first: $first, after: $after) {
      pageInfo { hasNextPage endCursor }
      edges { node {
        id title description handle tags
        collections(first: 10) { edges { node { title handle } } }
        images(first: 10) { edges { node { url altText } } }
        variants(first: 25) { edges { node {
          id title price { amount currencyCode } selectedOptions { name value }
        } } }
      } }
    }
  }`;

async function shopify(query, variables) {
  const res = await fetch(SHOPIFY_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Shopify-Storefront-Access-Token": SHOPIFY_TOKEN,
    },
    body: JSON.stringify({ query, variables }),
  });
  const json = await res.json();
  if (json.errors) throw new Error("Shopify: " + JSON.stringify(json.errors));
  return json.data;
}

async function fetchAllProducts() {
  const all = [];
  let after = null;
  do {
    const data = await shopify(PRODUCTS_QUERY, { first: 50, after });
    const conn = data.products;
    all.push(...conn.edges.map((e) => e.node));
    after = conn.pageInfo.hasNextPage ? conn.pageInfo.endCursor : null;
  } while (after);
  return all;
}

const toCents = (amount) => Math.round(parseFloat(amount) * 100);

async function upsertCollection(handle, title, position) {
  const { data, error } = await supabase
    .from("collections")
    .upsert({ handle, title: title ?? handle, position }, { onConflict: "handle" })
    .select("id")
    .single();
  if (error) throw new Error(`collection ${handle}: ${error.message}`);
  return data.id;
}

async function seed() {
  console.log("→ Descargando productos de Shopify…");
  const products = await fetchAllProducts();
  console.log(`  ${products.length} productos encontrados.`);

  // 1) Colecciones (dedupe por handle) con orden estable.
  const colMap = new Map(); // handle -> {title}
  for (const p of products) {
    for (const c of p.collections?.edges ?? []) {
      if (!colMap.has(c.node.handle)) colMap.set(c.node.handle, c.node.title);
    }
  }
  const colIds = new Map(); // handle -> id
  let ci = 0;
  for (const [handle, title] of colMap) {
    colIds.set(handle, await upsertCollection(handle, title, ci++));
  }
  console.log(`  ${colIds.size} colecciones.`);

  // 2) Productos + variantes + imágenes + enlaces de colección.
  let idx = 0;
  for (const p of products) {
    const { data: prod, error: prodErr } = await supabase
      .from("products")
      .upsert(
        {
          handle: p.handle,
          title: p.title,
          description: p.description ?? "",
          tags: p.tags ?? [],
          currency: p.variants.edges[0]?.node.price.currencyCode ?? "EUR",
          status: "active",
          position: idx++,
        },
        { onConflict: "handle" },
      )
      .select("id")
      .single();
    if (prodErr) throw new Error(`product ${p.handle}: ${prodErr.message}`);
    const productId = prod.id;

    // Reemplazar variantes / imágenes / enlaces (idempotencia).
    await supabase.from("product_variants").delete().eq("product_id", productId);
    await supabase.from("product_images").delete().eq("product_id", productId);
    await supabase.from("product_collections").delete().eq("product_id", productId);

    const variants = (p.variants?.edges ?? []).map((e, i) => ({
      product_id: productId,
      title: e.node.title || "Default Title",
      price_cents: toCents(e.node.price.amount),
      currency: e.node.price.currencyCode || "EUR",
      stock: DEFAULT_STOCK,
      selected_options: e.node.selectedOptions ?? [],
      position: i,
    }));
    if (variants.length) {
      const { error } = await supabase.from("product_variants").insert(variants);
      if (error) throw new Error(`variants ${p.handle}: ${error.message}`);
    }

    const images = (p.images?.edges ?? []).map((e, i) => ({
      product_id: productId,
      url: e.node.url,
      alt: e.node.altText ?? "",
      position: i,
    }));
    if (images.length) {
      const { error } = await supabase.from("product_images").insert(images);
      if (error) throw new Error(`images ${p.handle}: ${error.message}`);
    }

    const links = (p.collections?.edges ?? [])
      .map((e, i) => ({
        product_id: productId,
        collection_id: colIds.get(e.node.handle),
        position: i,
      }))
      .filter((l) => l.collection_id);
    if (links.length) {
      const { error } = await supabase.from("product_collections").insert(links);
      if (error) throw new Error(`links ${p.handle}: ${error.message}`);
    }
  }

  console.log(`✅ Seed completado: ${products.length} productos importados a Supabase.`);
  console.log(`   Stock por defecto asignado: ${DEFAULT_STOCK} u./variante (ajústalo en el panel).`);
}

seed().catch((err) => {
  console.error("❌ Seed falló:", err.message);
  process.exit(1);
});
