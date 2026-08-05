-- ============================================================================
-- Seed del catálogo (datos reales importados desde Shopify el 2026-08-03).
-- 68 productos. Idempotente: no duplica si ya existen.
-- Lo aplica Lovable automáticamente al sincronizar (no requiere acceso a Supabase).
-- Stock por defecto: 25 u./variante (ajústalo luego en el panel).
-- ============================================================================

-- Colecciones
INSERT INTO public.collections (handle, title, position) VALUES ('fundas-sublimacion', 'fundas-sublimacion', 0) ON CONFLICT (handle) DO NOTHING;

-- ipod — Kasea Dottie
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('ipod', 'Kasea Dottie', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 0)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'ipod'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00047.png?v=1785594944', '', 0
  FROM public.products p WHERE p.handle = 'ipod'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'ipod' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-amour — kasea Amour
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-amour', 'kasea Amour', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 1)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-amour'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00062.png?v=1785594501', '', 0
  FROM public.products p WHERE p.handle = 'kasea-amour'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-amour' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-coquette-pud — kasea coquette pud
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-coquette-pud', 'kasea coquette pud', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 2)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-coquette-pud'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00063.png?v=1785594406', '', 0
  FROM public.products p WHERE p.handle = 'kasea-coquette-pud'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-coquette-pud' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-luna — kasea Feline
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-luna', 'kasea Feline', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 3)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-luna'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00055.png?v=1785594312', '', 0
  FROM public.products p WHERE p.handle = 'kasea-luna'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-luna' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-minou — kasea Minou
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-minou', 'kasea Minou', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 4)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-minou'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00056.png?v=1785594217', '', 0
  FROM public.products p WHERE p.handle = 'kasea-minou'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-minou' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-noir — kasea Noir
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-noir', 'kasea Noir', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 5)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-noir'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00043.png?v=1785594131', '', 0
  FROM public.products p WHERE p.handle = 'kasea-noir'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-noir' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-douce — kasea Douce
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-douce', 'kasea Douce', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 6)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-douce'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00036.png?v=1785594052', '', 0
  FROM public.products p WHERE p.handle = 'kasea-douce'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-douce' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-charme — kasea Charme
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-charme', 'kasea Charme', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 7)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-charme'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00049.png?v=1785593989', '', 0
  FROM public.products p WHERE p.handle = 'kasea-charme'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-charme' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-loli — kasea Loli
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-loli', 'kasea Loli', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 8)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-loli'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00054.png?v=1785593895', '', 0
  FROM public.products p WHERE p.handle = 'kasea-loli'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-loli' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-ivory — kasea motif
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-ivory', 'kasea motif', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 9)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-ivory'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00040.png?v=1785593830', '', 0
  FROM public.products p WHERE p.handle = 'kasea-ivory'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-ivory' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-chic — kasea Coloria
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-chic', 'kasea Coloria', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 10)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-chic'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00034.png?v=1785593720', '', 0
  FROM public.products p WHERE p.handle = 'kasea-chic'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-chic' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-polka — kasea polka
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-polka', 'kasea polka', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 11)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-polka'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00032.png?v=1785593521', '', 0
  FROM public.products p WHERE p.handle = 'kasea-polka'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-polka' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-summer — kasea Aurea
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-summer', 'kasea Aurea', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 12)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-summer'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00026.png?v=1785593370', '', 0
  FROM public.products p WHERE p.handle = 'kasea-summer'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-summer' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-azure — kasea Azure
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-azure', 'kasea Azure', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 13)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-azure'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00050.png?v=1785593220', '', 0
  FROM public.products p WHERE p.handle = 'kasea-azure'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-azure' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-mare — kasea Mare
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-mare', 'kasea Mare', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 14)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-mare'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00037.png?v=1785592957', '', 0
  FROM public.products p WHERE p.handle = 'kasea-mare'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-mare' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-ivory-1 — kasea Ivory
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-ivory-1', 'kasea Ivory', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 15)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-ivory-1'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00069.png?v=1785592809', '', 0
  FROM public.products p WHERE p.handle = 'kasea-ivory-1'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-ivory-1' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-bora — kasea Bora
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-bora', 'kasea Bora', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY[]::text[], 'EUR', 'active', 16)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-bora'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00030.png?v=1785592707', '', 0
  FROM public.products p WHERE p.handle = 'kasea-bora'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-bora' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-cherry — kasea daisy
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-cherry', 'kasea daisy', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 17)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-cherry'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00033.png?v=1785592268', '', 0
  FROM public.products p WHERE p.handle = 'kasea-cherry'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-cherry' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-moka — kasea moka
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-moka', 'kasea moka', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 18)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-moka'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00025.png?v=1785592176', '', 0
  FROM public.products p WHERE p.handle = 'kasea-moka'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-moka' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-cherry-1 — kasea cherie
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-cherry-1', 'kasea cherie', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 19)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-cherry-1'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00022_a3eb5d26-700f-49b9-b4bc-f54d00b0d448.png?v=1785592016', '', 0
  FROM public.products p WHERE p.handle = 'kasea-cherry-1'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-cherry-1' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-chic-1 — kasea Chic
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-chic-1', 'kasea Chic', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 20)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-chic-1'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00029.png?v=1785591942', '', 0
  FROM public.products p WHERE p.handle = 'kasea-chic-1'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-chic-1' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-paris — kasea Paris
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-paris', 'kasea Paris', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 21)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-paris'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00027.png?v=1785591837', '', 0
  FROM public.products p WHERE p.handle = 'kasea-paris'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-paris' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-sicilia — kasea Sicilia
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-sicilia', 'kasea Sicilia', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 22)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-sicilia'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00024_9ccc6e18-efc1-4443-9dda-16076b8302a6.png?v=1785591775', '', 0
  FROM public.products p WHERE p.handle = 'kasea-sicilia'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-sicilia' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-lumiere — kasea Lumiere
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-lumiere', 'kasea Lumiere', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 23)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-lumiere'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00058.png?v=1785591714', '', 0
  FROM public.products p WHERE p.handle = 'kasea-lumiere'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-lumiere' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-petit-pois — kasea petit pois
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-petit-pois', 'kasea petit pois', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['SUBLIMACIÓN']::text[], 'EUR', 'active', 24)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-petit-pois'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00042.png?v=1785591618', '', 0
  FROM public.products p WHERE p.handle = 'kasea-petit-pois'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-petit-pois' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-douce-1 — kasea Belle
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-douce-1', 'kasea Belle', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 25)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-douce-1'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00028.png?v=1785591438', '', 0
  FROM public.products p WHERE p.handle = 'kasea-douce-1'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-douce-1' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-citrus — Kasea Citrius
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-citrus', 'Kasea Citrius', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 26)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-citrus'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00039.png?v=1785591340', '', 0
  FROM public.products p WHERE p.handle = 'kasea-citrus'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-citrus' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-fleur — Kasea Fleur
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-fleur', 'Kasea Fleur', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 27)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-fleur'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00067.png?v=1785591225', '', 0
  FROM public.products p WHERE p.handle = 'kasea-fleur'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-fleur' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-blossom — Kasea Blossom
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-blossom', 'Kasea Blossom', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 28)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-blossom'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00017.png?v=1785591147', '', 0
  FROM public.products p WHERE p.handle = 'kasea-blossom'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-blossom' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-flora — Kasea Flora
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-flora', 'Kasea Flora', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 29)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-flora'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00023_9d370a27-68c0-4443-ab6b-769488a634bf.png?v=1785591089', '', 0
  FROM public.products p WHERE p.handle = 'kasea-flora'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-flora' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-violet — Kasea Violet
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-violet', 'Kasea Violet', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 30)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-violet'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00038.png?v=1785591026', '', 0
  FROM public.products p WHERE p.handle = 'kasea-violet'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-violet' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-eden — Kasea Eden
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-eden', 'Kasea Eden', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 31)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-eden'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00064.png?v=1785590921', '', 0
  FROM public.products p WHERE p.handle = 'kasea-eden'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-eden' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-glow — Kasea Glow
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-glow', 'Kasea Glow', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 32)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-glow'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00021.png?v=1785590825', '', 0
  FROM public.products p WHERE p.handle = 'kasea-glow'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-glow' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-aura — Kasea Aura
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-aura', 'Kasea Aura', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 33)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-aura'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00016.png?v=1785590775', '', 0
  FROM public.products p WHERE p.handle = 'kasea-aura'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-aura' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-brisa — Kasea Brisa
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-brisa', 'Kasea Brisa', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 34)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-brisa'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00041.png?v=1785590716', '', 0
  FROM public.products p WHERE p.handle = 'kasea-brisa'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-brisa' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea — Kasea Ivy
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea', 'Kasea Ivy', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 35)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00019.png?v=1785590638', '', 0
  FROM public.products p WHERE p.handle = 'kasea'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-bora-1 — kasea Bora
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-bora-1', 'kasea Bora', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 36)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-bora-1'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00020.png?v=1785590586', '', 0
  FROM public.products p WHERE p.handle = 'kasea-bora-1'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-bora-1' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-iris — Kasea Iris
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-iris', 'Kasea Iris', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 37)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-iris'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00018.png?v=1785590529', '', 0
  FROM public.products p WHERE p.handle = 'kasea-iris'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-iris' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-wave — kasea wave
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-wave', 'kasea wave', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 38)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-wave'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00015.png?v=1785590431', '', 0
  FROM public.products p WHERE p.handle = 'kasea-wave'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-wave' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-daisy — kasea Daisy
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-daisy', 'kasea Daisy', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 39)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-daisy'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00014.png?v=1785590294', '', 0
  FROM public.products p WHERE p.handle = 'kasea-daisy'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-daisy' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-casely — Kasea casely
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-casely', 'Kasea casely', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 40)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-casely'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00045.png?v=1785595075', '', 0
  FROM public.products p WHERE p.handle = 'kasea-casely'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-casely' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-nubi — Kasea Nubi
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-nubi', 'Kasea Nubi', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 41)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-nubi'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00048.png?v=1785595470', '', 0
  FROM public.products p WHERE p.handle = 'kasea-nubi'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-nubi' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-pica — Kasea Pica
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-pica', 'Kasea Pica', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 42)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-pica'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00053.png?v=1785595711', '', 0
  FROM public.products p WHERE p.handle = 'kasea-pica'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-pica' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-pinti — Kasea Pinti
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-pinti', 'Kasea Pinti', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 43)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-pinti'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00046.png?v=1785595860', '', 0
  FROM public.products p WHERE p.handle = 'kasea-pinti'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-pinti' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-piccola — Kasea Piccola
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-piccola', 'Kasea Piccola', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 44)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-piccola'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00044.png?v=1785595959', '', 0
  FROM public.products p WHERE p.handle = 'kasea-piccola'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-piccola' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-kibi — Kasea Kibi
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-kibi', 'Kasea Kibi', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 45)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-kibi'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00051.png?v=1785596272', '', 0
  FROM public.products p WHERE p.handle = 'kasea-kibi'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-kibi' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-printo — Kasea Printo
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-printo', 'Kasea Printo', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 46)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-printo'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00052.png?v=1785596413', '', 0
  FROM public.products p WHERE p.handle = 'kasea-printo'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-printo' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-coffee — Kasea Coffee
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-coffee', 'Kasea Coffee', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 47)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-coffee'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00057.png?v=1785596760', '', 0
  FROM public.products p WHERE p.handle = 'kasea-coffee'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-coffee' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-yuni — Kasea Yuni
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-yuni', 'Kasea Yuni', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 48)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-yuni'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00059.png?v=1785596888', '', 0
  FROM public.products p WHERE p.handle = 'kasea-yuni'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-yuni' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-cheers — Kasea cheers
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-cheers', 'Kasea cheers', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 49)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-cheers'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00060.png?v=1785597054', '', 0
  FROM public.products p WHERE p.handle = 'kasea-cheers'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-cheers' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-mivo — Kasea Mivo
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-mivo', 'Kasea Mivo', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 50)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-mivo'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00061.png?v=1785597240', '', 0
  FROM public.products p WHERE p.handle = 'kasea-mivo'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-mivo' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-tiny — kasea tiny
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-tiny', 'kasea tiny', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 51)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-tiny'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00065.png?v=1785597324', '', 0
  FROM public.products p WHERE p.handle = 'kasea-tiny'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-tiny' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-joy — Kasea Joy
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-joy', 'Kasea Joy', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 52)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-joy'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00068.png?v=1785597443', '', 0
  FROM public.products p WHERE p.handle = 'kasea-joy'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-joy' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-dream — Kasea Dream
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-dream', 'Kasea Dream', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 53)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-dream'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00070.png?v=1785597700', '', 0
  FROM public.products p WHERE p.handle = 'kasea-dream'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-dream' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-vina — Kasea Viña
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-vina', 'Kasea Viña', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 54)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-vina'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00071.png?v=1785597817', '', 0
  FROM public.products p WHERE p.handle = 'kasea-vina'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-vina' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-cazy — kasea cazy
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-cazy', 'kasea cazy', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 55)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-cazy'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00072.png?v=1785597925', '', 0
  FROM public.products p WHERE p.handle = 'kasea-cazy'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-cazy' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-sof — Kasea sof
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-sof', 'Kasea sof', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 56)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-sof'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00073.png?v=1785598010', '', 0
  FROM public.products p WHERE p.handle = 'kasea-sof'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-sof' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-loqui — Kasea Loqui
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-loqui', 'Kasea Loqui', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 57)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-loqui'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00076.png?v=1785598112', '', 0
  FROM public.products p WHERE p.handle = 'kasea-loqui'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-loqui' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-reday — Kasea Reday
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-reday', 'Kasea Reday', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 58)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-reday'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00074.png?v=1785598220', '', 0
  FROM public.products p WHERE p.handle = 'kasea-reday'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-reday' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-lily — kasea Lily
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-lily', 'kasea Lily', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 59)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-lily'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00075.png?v=1785598368', '', 0
  FROM public.products p WHERE p.handle = 'kasea-lily'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-lily' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-pattern — Kasea Pattern
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-pattern', 'Kasea Pattern', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 60)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-pattern'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/image00077.png?v=1785598436', '', 0
  FROM public.products p WHERE p.handle = 'kasea-pattern'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-pattern' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- funda-personalizada — Funda personalizada
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('funda-personalizada', 'Funda personalizada', 'Funda personalizada con tu propia imagen, foto o diseño y el texto que elijas. El diseño se genera desde la web y se adjunta al pedido.', ARRAY['custom', 'personalizada']::text[], 'EUR', 'active', 61)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1999, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'funda-personalizada'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/WhatsAppImage2026-08-01at19.57.41.jpg?v=1785607144', '', 0
  FROM public.products p WHERE p.handle = 'funda-personalizada'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);

-- kasea-fogue — Kasea Fogue
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-fogue', 'Kasea Fogue', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 62)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-fogue'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/EFF76D5E-008B-4A75-9491-657A71E25B9D.png?v=1785606246', '', 0
  FROM public.products p WHERE p.handle = 'kasea-fogue'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-fogue' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-titan — Kasea Titan
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-titan', 'Kasea Titan', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 63)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-titan'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/66B09631-908C-4D08-9E8C-901BB2AE5A1D.png?v=1785606319', '', 0
  FROM public.products p WHERE p.handle = 'kasea-titan'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-titan' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-atlas — kasea Atlas
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-atlas', 'kasea Atlas', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 64)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-atlas'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/86A1C061-7E05-46EA-AD8F-4DB3EAF94A8F.png?v=1785606447', '', 0
  FROM public.products p WHERE p.handle = 'kasea-atlas'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-atlas' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-eyes — Kasea Eyes
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-eyes', 'Kasea Eyes', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 65)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-eyes'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/3C017087-ECFB-40B0-9F90-26F7A85025D5.png?v=1785606498', '', 0
  FROM public.products p WHERE p.handle = 'kasea-eyes'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-eyes' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-happy — Kasea Happy
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-happy', 'Kasea Happy', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 66)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-happy'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/C22A5D47-F995-47E5-9F70-BC9A35F145FF.png?v=1785606549', '', 0
  FROM public.products p WHERE p.handle = 'kasea-happy'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-happy' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;

-- kasea-urban — Kasea Urban
INSERT INTO public.products (handle, title, description, tags, currency, status, position)
  VALUES ('kasea-urban', 'Kasea Urban', 'Funda con acabado de alta calidad, resistente y ligera, creada para proteger tu móvil con un estilo único.', ARRAY['Fundas']::text[], 'EUR', 'active', 67)
  ON CONFLICT (handle) DO NOTHING;
INSERT INTO public.product_variants (product_id, title, price_cents, currency, stock, selected_options, position)
  SELECT p.id, 'Default Title', 1499, 'EUR', 25, '[{"name":"Title","value":"Default Title"}]'::jsonb, 0
  FROM public.products p WHERE p.handle = 'kasea-urban'
    AND NOT EXISTS (SELECT 1 FROM public.product_variants x WHERE x.product_id = p.id);
INSERT INTO public.product_images (product_id, url, alt, position)
  SELECT p.id, 'https://cdn.shopify.com/s/files/1/1004/7681/3686/files/KaseaUrban.png?v=1785625986', '', 0
  FROM public.products p WHERE p.handle = 'kasea-urban'
    AND NOT EXISTS (SELECT 1 FROM public.product_images x WHERE x.product_id = p.id);
INSERT INTO public.product_collections (product_id, collection_id, position)
  SELECT p.id, c.id, 0 FROM public.products p, public.collections c
  WHERE p.handle = 'kasea-urban' AND c.handle = 'fundas-sublimacion'
  ON CONFLICT (product_id, collection_id) DO NOTHING;
