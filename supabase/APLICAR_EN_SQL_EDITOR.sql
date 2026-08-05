-- ============================================================================
-- Kasea Store — configuración COMPLETA de la base de datos.
-- Pega TODO esto en el SQL Editor de un proyecto Supabase NUEVO/VACÍO y Run.
-- Incluye TODAS las migraciones (base + tienda) en orden. Ejecutar UNA vez.
-- Después: crea el usuario admin (ver DEPLOY.md) y el bucket 'site-images'.
-- ============================================================================

-- ===================== 20260711205520_e5cfd247-4cf8-4393-8eb6-dbf4003a3f71.sql =====================

-- Roles enum + user_roles table + has_role function
CREATE TYPE public.app_role AS ENUM ('admin');

CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role public.app_role NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);

GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own roles"
  ON public.user_roles FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role public.app_role)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;

-- Carousel images table
CREATE TABLE public.carousel_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  image_key TEXT NOT NULL UNIQUE,
  alt TEXT NOT NULL DEFAULT '',
  position INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.carousel_images TO anon;
GRANT SELECT, UPDATE ON public.carousel_images TO authenticated;
GRANT ALL ON public.carousel_images TO service_role;

ALTER TABLE public.carousel_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Carousel images are viewable by everyone"
  ON public.carousel_images FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can update carousel images"
  ON public.carousel_images FOR UPDATE
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

-- Seed initial carousel data (9 uploaded images)
INSERT INTO public.carousel_images (image_key, alt, position) VALUES
  ('carousel-01', 'Funda Kasea lila con rayas y motivo veraniego', 1),
  ('carousel-02', 'Funda Kasea turquesa con rayas y detalle gráfico rojo', 2),
  ('carousel-03', 'Funda Kasea con rayas celestes y motivo de langosta', 3),
  ('carousel-04', 'Funda Kasea de lunares con ilustración femenina', 4),
  ('carousel-05', 'Funda Kasea de rayas azul marino con perro y taza', 5),
  ('carousel-06', 'Funda Kasea rosa con lunares y gato ilustrado', 6),
  ('carousel-07', 'Funda Kasea rosa con espiral y gato negro', 7),
  ('carousel-08', 'Funda Kasea de lunares con perro y pañuelo animal print', 8),
  ('carousel-09', 'Funda Kasea rosa con corazones y gato', 9);

-- ===================== 20260711205544_895d6524-287e-4625-bace-49ea3e61d5a7.sql =====================

REVOKE EXECUTE ON FUNCTION public.has_role(uuid, public.app_role) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.has_role(uuid, public.app_role) TO authenticated, service_role;

-- ===================== 20260712065957_77c37b17-d2f3-4cf7-98ed-011fa4576419.sql =====================

-- Extend carousel_images
ALTER TABLE public.carousel_images 
  ADD COLUMN IF NOT EXISTS title text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS description text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS image_url text NOT NULL DEFAULT '';

-- Admin write policies for carousel_images
CREATE POLICY "Admins can insert carousel images"
  ON public.carousel_images FOR INSERT TO authenticated
  WITH CHECK (public.has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Admins can delete carousel images"
  ON public.carousel_images FOR DELETE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::app_role));

-- product_image_overrides
CREATE TABLE public.product_image_overrides (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_handle text NOT NULL,
  position integer NOT NULL,
  image_url text NOT NULL,
  title text NOT NULL DEFAULT '',
  alt text NOT NULL DEFAULT '',
  is_uploaded boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX product_image_overrides_handle_idx ON public.product_image_overrides(product_handle, position);

GRANT SELECT ON public.product_image_overrides TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.product_image_overrides TO authenticated;
GRANT ALL ON public.product_image_overrides TO service_role;

ALTER TABLE public.product_image_overrides ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read product image overrides"
  ON public.product_image_overrides FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admins can insert product image overrides"
  ON public.product_image_overrides FOR INSERT TO authenticated
  WITH CHECK (public.has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Admins can update product image overrides"
  ON public.product_image_overrides FOR UPDATE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (public.has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Admins can delete product image overrides"
  ON public.product_image_overrides FOR DELETE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::app_role));

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
  RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$
  LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER update_product_image_overrides_updated_at
  BEFORE UPDATE ON public.product_image_overrides
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Admin write policies for user_roles (so first admin can be created via SQL by service role, others by admins)
CREATE POLICY "Admins can insert user roles"
  ON public.user_roles FOR INSERT TO authenticated
  WITH CHECK (public.has_role(auth.uid(), 'admin'::app_role));
CREATE POLICY "Admins can delete user roles"
  ON public.user_roles FOR DELETE TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::app_role));

-- ===================== 20260712070108_8f87230c-4772-4ed1-a3f6-4d2d23687ca8.sql =====================

CREATE POLICY "Public read site-images" ON storage.objects
  FOR SELECT TO anon, authenticated
  USING (bucket_id = 'site-images');

CREATE POLICY "Admins can upload to site-images" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'site-images' AND public.has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update site-images" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'site-images' AND public.has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete site-images" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'site-images' AND public.has_role(auth.uid(), 'admin'::app_role));

-- ===================== 20260712073151_722a24c8-cdf8-4bd6-9e33-32211bd98276.sql =====================
CREATE TABLE public.product_order (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_handle text NOT NULL UNIQUE,
  position integer NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT ON public.product_order TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.product_order TO authenticated;
GRANT ALL ON public.product_order TO service_role;

ALTER TABLE public.product_order ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Product order is viewable by everyone"
  ON public.product_order FOR SELECT
  TO anon, authenticated USING (true);

CREATE POLICY "Admins can insert product order"
  ON public.product_order FOR INSERT
  TO authenticated WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update product order"
  ON public.product_order FOR UPDATE
  TO authenticated USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete product order"
  ON public.product_order FOR DELETE
  TO authenticated USING (has_role(auth.uid(), 'admin'::app_role));

CREATE TRIGGER update_product_order_updated_at
  BEFORE UPDATE ON public.product_order
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
-- ===================== 20260712131319_727c70a5-388f-4aca-b017-a0ce26c7861a.sql =====================

CREATE TABLE public.category_images (
  slug TEXT PRIMARY KEY,
  image_url TEXT NOT NULL,
  alt TEXT NOT NULL DEFAULT '',
  title TEXT NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.category_images TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.category_images TO authenticated;
GRANT ALL ON public.category_images TO service_role;

ALTER TABLE public.category_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Category images are viewable by everyone"
ON public.category_images FOR SELECT
USING (true);

CREATE POLICY "Admins can insert category images"
ON public.category_images FOR INSERT TO authenticated
WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update category images"
ON public.category_images FOR UPDATE TO authenticated
USING (public.has_role(auth.uid(), 'admin'))
WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete category images"
ON public.category_images FOR DELETE TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

CREATE TRIGGER update_category_images_updated_at
BEFORE UPDATE ON public.category_images
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ===================== 20260801181923_a3b7a0fa-a64b-4db3-a88f-83d2e11874c7.sql =====================
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role app_role)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
      AND (auth.uid() = _user_id OR auth.role() = 'service_role')
  )
$function$;

REVOKE ALL ON FUNCTION public.has_role(uuid, app_role) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.has_role(uuid, app_role) TO authenticated, service_role;

REVOKE ALL ON FUNCTION public.update_updated_at_column() FROM PUBLIC, anon, authenticated;
-- ===================== 20260801182018_572075cf-9884-4b93-ab85-1153022d71ae.sql =====================
CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION private.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$function$;

REVOKE ALL ON FUNCTION private.has_role(uuid, public.app_role) FROM PUBLIC, anon, authenticated;

DROP POLICY IF EXISTS "Admins can update carousel images" ON public.carousel_images;
DROP POLICY IF EXISTS "Admins can insert carousel images" ON public.carousel_images;
DROP POLICY IF EXISTS "Admins can delete carousel images" ON public.carousel_images;
CREATE POLICY "Admins can update carousel images" ON public.carousel_images FOR UPDATE TO authenticated USING (private.has_role(auth.uid(), 'admin')) WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert carousel images" ON public.carousel_images FOR INSERT TO authenticated WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete carousel images" ON public.carousel_images FOR DELETE TO authenticated USING (private.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Admins can update category images" ON public.category_images;
DROP POLICY IF EXISTS "Admins can insert category images" ON public.category_images;
DROP POLICY IF EXISTS "Admins can delete category images" ON public.category_images;
CREATE POLICY "Admins can update category images" ON public.category_images FOR UPDATE TO authenticated USING (private.has_role(auth.uid(), 'admin')) WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert category images" ON public.category_images FOR INSERT TO authenticated WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete category images" ON public.category_images FOR DELETE TO authenticated USING (private.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Admins can update product image overrides" ON public.product_image_overrides;
DROP POLICY IF EXISTS "Admins can insert product image overrides" ON public.product_image_overrides;
DROP POLICY IF EXISTS "Admins can delete product image overrides" ON public.product_image_overrides;
CREATE POLICY "Admins can update product image overrides" ON public.product_image_overrides FOR UPDATE TO authenticated USING (private.has_role(auth.uid(), 'admin')) WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert product image overrides" ON public.product_image_overrides FOR INSERT TO authenticated WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete product image overrides" ON public.product_image_overrides FOR DELETE TO authenticated USING (private.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Admins can update product order" ON public.product_order;
DROP POLICY IF EXISTS "Admins can insert product order" ON public.product_order;
DROP POLICY IF EXISTS "Admins can delete product order" ON public.product_order;
CREATE POLICY "Admins can update product order" ON public.product_order FOR UPDATE TO authenticated USING (private.has_role(auth.uid(), 'admin')) WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert product order" ON public.product_order FOR INSERT TO authenticated WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete product order" ON public.product_order FOR DELETE TO authenticated USING (private.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Admins can delete user roles" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can insert user roles" ON public.user_roles;
CREATE POLICY "Admins can delete user roles" ON public.user_roles FOR DELETE TO authenticated USING (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert user roles" ON public.user_roles FOR INSERT TO authenticated WITH CHECK (private.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Admins can upload to site-images" ON storage.objects;
DROP POLICY IF EXISTS "Admins can update site-images" ON storage.objects;
DROP POLICY IF EXISTS "Admins can delete site-images" ON storage.objects;
CREATE POLICY "Admins can upload to site-images" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'site-images' AND private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can update site-images" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'site-images' AND private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete site-images" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'site-images' AND private.has_role(auth.uid(), 'admin'));

DROP FUNCTION IF EXISTS public.has_role(uuid, public.app_role);
-- ===================== 20260803120000_catalog.sql =====================
-- ============================================================================
-- Catálogo propio en Supabase (reemplaza el catálogo alojado en Shopify)
--
-- Tablas:
--   collections           colecciones/categorías
--   products              productos (handle = mismo slug que tenía en Shopify)
--   product_variants      variantes; AQUÍ vive el STOCK (fuente de verdad)
--   product_images        imágenes base del producto
--   product_collections   relación N:N producto <-> colección
--
-- Notas de diseño:
--   - `products.handle` conserva el handle de Shopify para que las tablas
--     existentes (product_order, product_image_overrides), que referencian
--     por `product_handle`, sigan funcionando sin cambios.
--   - Precios en CÉNTIMOS (integer) para evitar errores de coma flotante.
--   - `product_variants.stock` con CHECK (stock >= 0): barrera a nivel de BD
--     contra sobreventa. En la Fase 4 el descuento será atómico y condicional.
--   - RLS: lectura pública (solo productos 'active'); escritura solo admin.
--   - Reutiliza el trigger public.update_updated_at_column() ya existente.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- has_role(): garantizar que exista en public para las políticas de abajo.
-- (Una migración base anterior movió la función al esquema private y eliminó
-- la versión public; aquí la recreamos para que las RLS de la tienda funcionen.)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role
  )
$$;
GRANT EXECUTE ON FUNCTION public.has_role(uuid, public.app_role) TO authenticated, service_role;

-- ---------------------------------------------------------------------------
-- collections
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.collections (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  handle      text NOT NULL UNIQUE,
  title       text NOT NULL DEFAULT '',
  description text NOT NULL DEFAULT '',
  position    integer NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- products
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.products (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  handle      text NOT NULL UNIQUE,
  title       text NOT NULL,
  description text NOT NULL DEFAULT '',
  tags        text[] NOT NULL DEFAULT '{}',
  currency    text NOT NULL DEFAULT 'EUR',
  status      text NOT NULL DEFAULT 'active'
              CHECK (status IN ('active', 'draft', 'archived')),
  position    integer NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- product_variants  (incluye STOCK)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.product_variants (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id       uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  title            text NOT NULL DEFAULT 'Default Title',
  price_cents      integer NOT NULL CHECK (price_cents >= 0),
  currency         text NOT NULL DEFAULT 'EUR',
  stock            integer NOT NULL DEFAULT 0 CHECK (stock >= 0),
  sku              text,
  selected_options jsonb NOT NULL DEFAULT '[]'::jsonb,
  position         integer NOT NULL DEFAULT 0,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_product_variants_product_id
  ON public.product_variants(product_id);

-- ---------------------------------------------------------------------------
-- product_images
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.product_images (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  url        text NOT NULL,
  alt        text NOT NULL DEFAULT '',
  position   integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_product_images_product_id
  ON public.product_images(product_id);

-- ---------------------------------------------------------------------------
-- product_collections  (N:N)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.product_collections (
  product_id    uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  collection_id uuid NOT NULL REFERENCES public.collections(id) ON DELETE CASCADE,
  position      integer NOT NULL DEFAULT 0,
  PRIMARY KEY (product_id, collection_id)
);
CREATE INDEX IF NOT EXISTS idx_product_collections_collection_id
  ON public.product_collections(collection_id);

-- ===========================================================================
-- GRANTS
-- ===========================================================================
GRANT SELECT ON public.collections         TO anon, authenticated;
GRANT SELECT ON public.products            TO anon, authenticated;
GRANT SELECT ON public.product_variants    TO anon, authenticated;
GRANT SELECT ON public.product_images      TO anon, authenticated;
GRANT SELECT ON public.product_collections TO anon, authenticated;

GRANT INSERT, UPDATE, DELETE ON public.collections         TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.products            TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.product_variants    TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.product_images      TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.product_collections TO authenticated;

GRANT ALL ON public.collections         TO service_role;
GRANT ALL ON public.products            TO service_role;
GRANT ALL ON public.product_variants    TO service_role;
GRANT ALL ON public.product_images      TO service_role;
GRANT ALL ON public.product_collections TO service_role;

-- ===========================================================================
-- ROW LEVEL SECURITY
-- ===========================================================================
ALTER TABLE public.collections         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_collections ENABLE ROW LEVEL SECURITY;

-- ---- products: lectura pública solo de 'active'; admin ve todo ----
CREATE POLICY "Public can read active products"
  ON public.products FOR SELECT
  TO anon, authenticated
  USING (status = 'active');

CREATE POLICY "Admins can read all products"
  ON public.products FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can insert products"
  ON public.products FOR INSERT
  TO authenticated
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update products"
  ON public.products FOR UPDATE
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete products"
  ON public.products FOR DELETE
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role));

-- ---- collections / variants / images / product_collections ----
-- Lectura pública (los datos no son sensibles y se sirven vía server functions
-- que solo devuelven productos 'active'); escritura solo admin.
DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'collections', 'product_variants', 'product_images', 'product_collections'
  ]
  LOOP
    EXECUTE format(
      'CREATE POLICY "Public read %1$s" ON public.%1$s
         FOR SELECT TO anon, authenticated USING (true);', t);
    EXECUTE format(
      'CREATE POLICY "Admins insert %1$s" ON public.%1$s
         FOR INSERT TO authenticated
         WITH CHECK (has_role(auth.uid(), ''admin''::app_role));', t);
    EXECUTE format(
      'CREATE POLICY "Admins update %1$s" ON public.%1$s
         FOR UPDATE TO authenticated
         USING (has_role(auth.uid(), ''admin''::app_role))
         WITH CHECK (has_role(auth.uid(), ''admin''::app_role));', t);
    EXECUTE format(
      'CREATE POLICY "Admins delete %1$s" ON public.%1$s
         FOR DELETE TO authenticated
         USING (has_role(auth.uid(), ''admin''::app_role));', t);
  END LOOP;
END $$;

-- ===========================================================================
-- TRIGGERS updated_at
-- ===========================================================================
CREATE TRIGGER update_collections_updated_at
  BEFORE UPDATE ON public.collections
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_product_variants_updated_at
  BEFORE UPDATE ON public.product_variants
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ===================== 20260803120100_catalog_seed.sql =====================
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

-- ===================== 20260803120200_orders.sql =====================
-- ============================================================================
-- Pedidos + descuento de stock ATÓMICO (núcleo de la Fase 4)
--
--   orders          cabecera del pedido (datos de envío, importes, estado)
--   order_items     líneas del pedido (snapshot de título/precio)
--   stripe_events   idempotencia a nivel de evento de Stripe
--
--   process_paid_order()  función transaccional que:
--     - es IDEMPOTENTE por stripe_session_id (Stripe reintenta webhooks),
--     - descuenta stock de forma CONDICIONAL (stock >= cantidad): nunca deja
--       stock negativo ni vende de más, incluso con compras simultáneas,
--     - marca needs_review si hubo una carrera por la última unidad.
--
-- Seguridad: los pedidos contienen datos personales -> solo el admin los lee.
-- La escritura la hace el webhook con la service_role (bypassa RLS).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- orders
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.orders (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  stripe_session_id      text NOT NULL UNIQUE,
  stripe_payment_intent  text,
  email                  text,
  customer_name          text,
  phone                  text,
  shipping_address       jsonb,
  currency               text NOT NULL DEFAULT 'EUR',
  subtotal_cents         integer NOT NULL DEFAULT 0,
  shipping_cents         integer NOT NULL DEFAULT 0,
  total_cents            integer NOT NULL DEFAULT 0,
  status                 text NOT NULL DEFAULT 'paid'
                         CHECK (status IN ('pending', 'paid', 'fulfilled', 'cancelled', 'refunded')),
  needs_review           boolean NOT NULL DEFAULT false,
  created_at             timestamptz NOT NULL DEFAULT now(),
  updated_at             timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- order_items  (snapshot: sobrevive a cambios/borrados de producto)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.order_items (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id         uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  variant_id       uuid REFERENCES public.product_variants(id) ON DELETE SET NULL,
  product_handle   text,
  title            text NOT NULL,
  unit_price_cents integer NOT NULL DEFAULT 0,
  quantity         integer NOT NULL DEFAULT 1,
  attributes       jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at       timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);

-- ---------------------------------------------------------------------------
-- stripe_events  (idempotencia a nivel de evento)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.stripe_events (
  id         text PRIMARY KEY,          -- id del evento de Stripe (evt_...)
  type       text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ===========================================================================
-- GRANTS + RLS
-- ===========================================================================
-- Nada para anon. El admin (authenticated) solo LEE. service_role todo.
GRANT SELECT ON public.orders      TO authenticated;
GRANT SELECT ON public.order_items TO authenticated;
GRANT ALL    ON public.orders        TO service_role;
GRANT ALL    ON public.order_items   TO service_role;
GRANT ALL    ON public.stripe_events TO service_role;

ALTER TABLE public.orders        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stripe_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can read orders"
  ON public.orders FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update orders"
  ON public.orders FOR UPDATE
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can read order items"
  ON public.order_items FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role));

-- stripe_events: sin políticas para authenticated/anon (solo service_role, que
-- bypassa RLS). Queda bloqueado para el resto.

CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ===========================================================================
-- process_paid_order()  — atómico + idempotente
-- ===========================================================================
CREATE OR REPLACE FUNCTION public.process_paid_order(
  _session_id      text,
  _payment_intent  text,
  _email           text,
  _name            text,
  _phone           text,
  _address         jsonb,
  _currency        text,
  _subtotal_cents  integer,
  _shipping_cents  integer,
  _total_cents     integer,
  _items           jsonb   -- [{variant_id, product_handle, title, unit_price_cents, quantity, attributes}]
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _order_id  uuid;
  _existing  uuid;
  _item      jsonb;
  _qty       integer;
  _updated   integer;
  _oversold  jsonb := '[]'::jsonb;
  _review    boolean := false;
BEGIN
  -- Idempotencia: si ya existe un pedido para esta sesión, no reprocesar.
  SELECT id INTO _existing FROM public.orders WHERE stripe_session_id = _session_id;
  IF _existing IS NOT NULL THEN
    RETURN jsonb_build_object('order_id', _existing, 'already_processed', true);
  END IF;

  INSERT INTO public.orders (
    stripe_session_id, stripe_payment_intent, email, customer_name, phone,
    shipping_address, currency, subtotal_cents, shipping_cents, total_cents, status
  ) VALUES (
    _session_id, _payment_intent, _email, _name, _phone,
    _address, COALESCE(_currency, 'EUR'),
    COALESCE(_subtotal_cents, 0), COALESCE(_shipping_cents, 0), COALESCE(_total_cents, 0),
    'paid'
  )
  RETURNING id INTO _order_id;

  FOR _item IN SELECT * FROM jsonb_array_elements(COALESCE(_items, '[]'::jsonb))
  LOOP
    _qty := COALESCE((_item->>'quantity')::int, 1);

    -- Decremento ATÓMICO y CONDICIONAL: solo baja si hay stock suficiente.
    UPDATE public.product_variants
      SET stock = stock - _qty
      WHERE id = NULLIF(_item->>'variant_id', '')::uuid
        AND stock >= _qty;
    GET DIAGNOSTICS _updated = ROW_COUNT;

    IF _updated = 0 THEN
      -- Carrera por la última unidad (o variante inexistente): registrar y
      -- marcar para revisión. Clamp defensivo a 0 (nunca negativo).
      _review := true;
      _oversold := _oversold || jsonb_build_object(
        'variant_id', _item->>'variant_id',
        'title', _item->>'title',
        'quantity', _qty
      );
      UPDATE public.product_variants
        SET stock = 0
        WHERE id = NULLIF(_item->>'variant_id', '')::uuid AND stock < _qty;
    END IF;

    INSERT INTO public.order_items (
      order_id, variant_id, product_handle, title, unit_price_cents, quantity, attributes
    ) VALUES (
      _order_id,
      NULLIF(_item->>'variant_id', '')::uuid,
      _item->>'product_handle',
      COALESCE(_item->>'title', 'Producto'),
      COALESCE((_item->>'unit_price_cents')::int, 0),
      _qty,
      COALESCE(_item->'attributes', '[]'::jsonb)
    );
  END LOOP;

  IF _review THEN
    UPDATE public.orders SET needs_review = true WHERE id = _order_id;
  END IF;

  RETURN jsonb_build_object('order_id', _order_id, 'already_processed', false, 'oversold', _oversold);
END $$;

-- Solo el rol de servicio (webhook) puede ejecutarla.
REVOKE ALL ON FUNCTION public.process_paid_order(text, text, text, text, text, jsonb, text, integer, integer, integer, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.process_paid_order(text, text, text, text, text, jsonb, text, integer, integer, integer, jsonb) TO service_role;

-- ===================== 20260803120300_settings_custom_pickup.sql =====================
-- ============================================================================
-- Retrofit (Fase 4.5): ajustes editables, funda personalizada y recogida en tienda
--
--   shop_settings   tarifa/umbral de envío EDITABLES desde el admin
--   products.is_custom  distingue catálogo (con stock) de personalizada (sin stock)
--   custom_designs  todos los datos del diseño personalizado (para producción)
--   order_items.custom_design_id  enlaza la línea con su diseño
--   orders.delivery_method  'delivery' (envío) | 'pickup' (recoger en tienda)
--
--   process_paid_order() v2: NO descuenta stock en productos personalizados
--   (bajo pedido) y guarda método de entrega + diseño.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- shop_settings (una sola fila, editable por el admin)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.shop_settings (
  id                            text PRIMARY KEY DEFAULT 'default' CHECK (id = 'default'),
  shipping_flat_cents           integer NOT NULL DEFAULT 699,   -- 6,99 €
  shipping_free_threshold_cents integer NOT NULL DEFAULT 5500,  -- gratis desde 55 €
  updated_at                    timestamptz NOT NULL DEFAULT now()
);
INSERT INTO public.shop_settings (id) VALUES ('default') ON CONFLICT (id) DO NOTHING;

GRANT SELECT ON public.shop_settings TO anon, authenticated;
GRANT UPDATE ON public.shop_settings TO authenticated;
GRANT ALL    ON public.shop_settings TO service_role;

ALTER TABLE public.shop_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read shop settings"
  ON public.shop_settings FOR SELECT
  TO anon, authenticated USING (true);

CREATE POLICY "Admins update shop settings"
  ON public.shop_settings FOR UPDATE
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE TRIGGER update_shop_settings_updated_at
  BEFORE UPDATE ON public.shop_settings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ---------------------------------------------------------------------------
-- products.is_custom  (personalizada = sin stock, fuera del listado de catálogo)
-- ---------------------------------------------------------------------------
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS is_custom boolean NOT NULL DEFAULT false;
UPDATE public.products SET is_custom = true WHERE handle = 'funda-personalizada';

-- ---------------------------------------------------------------------------
-- custom_designs  (todos los datos del diseño, para producción)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.custom_designs (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  model         text,
  image_url     text,           -- imagen subida por el cliente (Supabase Storage)
  preview_url   text,           -- vista previa del diseño final compuesto
  text_content  text,
  font          text,
  color         text,
  font_size     numeric,
  pos_x         numeric,
  pos_y         numeric,
  rotation      numeric,
  params        jsonb NOT NULL DEFAULT '{}'::jsonb,  -- resto de parámetros
  created_at    timestamptz NOT NULL DEFAULT now()
);

GRANT INSERT ON public.custom_designs TO anon, authenticated;
GRANT SELECT ON public.custom_designs TO authenticated;
GRANT ALL    ON public.custom_designs TO service_role;

ALTER TABLE public.custom_designs ENABLE ROW LEVEL SECURITY;

-- Cualquiera puede CREAR un diseño (forma parte de la compra como invitado).
CREATE POLICY "Anyone can create a design"
  ON public.custom_designs FOR INSERT
  TO anon, authenticated WITH CHECK (true);

-- Solo el admin puede LEER los diseños.
CREATE POLICY "Admins read designs"
  ON public.custom_designs FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role));

-- ---------------------------------------------------------------------------
-- order_items.custom_design_id  +  orders.delivery_method
-- ---------------------------------------------------------------------------
ALTER TABLE public.order_items
  ADD COLUMN IF NOT EXISTS custom_design_id uuid REFERENCES public.custom_designs(id) ON DELETE SET NULL;

ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS delivery_method text NOT NULL DEFAULT 'delivery'
  CHECK (delivery_method IN ('delivery', 'pickup'));

-- ---------------------------------------------------------------------------
-- process_paid_order() v2
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.process_paid_order(
  text, text, text, text, text, jsonb, text, integer, integer, integer, jsonb
);

CREATE OR REPLACE FUNCTION public.process_paid_order(
  _session_id       text,
  _payment_intent   text,
  _email            text,
  _name             text,
  _phone            text,
  _address          jsonb,
  _delivery_method  text,
  _currency         text,
  _subtotal_cents   integer,
  _shipping_cents   integer,
  _total_cents      integer,
  _items            jsonb   -- [{variant_id, product_handle, title, unit_price_cents, quantity, attributes, custom_design_id}]
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _order_id   uuid;
  _existing   uuid;
  _item       jsonb;
  _qty        integer;
  _updated    integer;
  _is_custom  boolean;
  _oversold   jsonb := '[]'::jsonb;
  _review     boolean := false;
BEGIN
  -- Idempotencia por sesión.
  SELECT id INTO _existing FROM public.orders WHERE stripe_session_id = _session_id;
  IF _existing IS NOT NULL THEN
    RETURN jsonb_build_object('order_id', _existing, 'already_processed', true);
  END IF;

  INSERT INTO public.orders (
    stripe_session_id, stripe_payment_intent, email, customer_name, phone,
    shipping_address, delivery_method, currency,
    subtotal_cents, shipping_cents, total_cents, status
  ) VALUES (
    _session_id, _payment_intent, _email, _name, _phone,
    _address, COALESCE(NULLIF(_delivery_method, ''), 'delivery'), COALESCE(_currency, 'EUR'),
    COALESCE(_subtotal_cents, 0), COALESCE(_shipping_cents, 0), COALESCE(_total_cents, 0),
    'paid'
  )
  RETURNING id INTO _order_id;

  FOR _item IN SELECT * FROM jsonb_array_elements(COALESCE(_items, '[]'::jsonb))
  LOOP
    _qty := COALESCE((_item->>'quantity')::int, 1);

    -- ¿Es un producto personalizado? (fuente de verdad: la BD, no el cliente)
    _is_custom := COALESCE((
      SELECT p.is_custom
      FROM public.product_variants v
      JOIN public.products p ON p.id = v.product_id
      WHERE v.id = NULLIF(_item->>'variant_id', '')::uuid
    ), false);

    IF NOT _is_custom THEN
      -- Catálogo: descuento ATÓMICO y CONDICIONAL (nunca negativo, sin sobreventa).
      UPDATE public.product_variants
        SET stock = stock - _qty
        WHERE id = NULLIF(_item->>'variant_id', '')::uuid
          AND stock >= _qty;
      GET DIAGNOSTICS _updated = ROW_COUNT;

      IF _updated = 0 THEN
        _review := true;
        _oversold := _oversold || jsonb_build_object(
          'variant_id', _item->>'variant_id', 'title', _item->>'title', 'quantity', _qty
        );
        UPDATE public.product_variants
          SET stock = 0
          WHERE id = NULLIF(_item->>'variant_id', '')::uuid AND stock < _qty;
      END IF;
    END IF;
    -- Personalizada: bajo pedido, NO se toca el stock.

    INSERT INTO public.order_items (
      order_id, variant_id, product_handle, title, unit_price_cents, quantity, attributes, custom_design_id
    ) VALUES (
      _order_id,
      NULLIF(_item->>'variant_id', '')::uuid,
      _item->>'product_handle',
      COALESCE(_item->>'title', 'Producto'),
      COALESCE((_item->>'unit_price_cents')::int, 0),
      _qty,
      COALESCE(_item->'attributes', '[]'::jsonb),
      NULLIF(_item->>'custom_design_id', '')::uuid
    );
  END LOOP;

  IF _review THEN
    UPDATE public.orders SET needs_review = true WHERE id = _order_id;
  END IF;

  RETURN jsonb_build_object('order_id', _order_id, 'already_processed', false, 'oversold', _oversold);
END $$;

REVOKE ALL ON FUNCTION public.process_paid_order(text, text, text, text, text, jsonb, text, text, integer, integer, integer, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.process_paid_order(text, text, text, text, text, jsonb, text, text, integer, integer, integer, jsonb) TO service_role;

-- ===================== 20260803120400_notify_email.sql =====================
-- ============================================================================
-- Correo de avisos al administrador (editable en el panel → Ajustes).
-- Al confirmarse un pedido, además del correo al cliente, se envía un aviso a
-- esta dirección con el resumen y, si es funda personalizada, el diseño.
-- ============================================================================
ALTER TABLE public.shop_settings ADD COLUMN IF NOT EXISTS notify_email text;

-- ===================== 20260803120500_grant_private_has_role.sql =====================
-- ============================================================================
-- Fix de permisos: las políticas RLS heredadas de Lovable (Storage, carrusel,
-- categorías, overrides de imágenes, orden de productos, roles) usan
-- private.has_role(), pero una migración base le REVOCÓ el permiso de ejecución
-- a 'authenticated' → daba "permission denied for function has_role" al subir
-- imágenes o guardar el carrusel/categorías desde el panel.
--
-- Concedemos EXECUTE a authenticated. Sigue sin ser accesible por la API REST
-- porque el esquema 'private' no está expuesto en PostgREST.
-- ============================================================================
GRANT EXECUTE ON FUNCTION private.has_role(uuid, public.app_role) TO authenticated;

-- ===================== 20260803120600_fix_table_grants.sql =====================
-- ============================================================================
-- Cierre de huecos de permisos a nivel de TABLA para el rol 'authenticated'.
-- (Las escrituras del admin ya están protegidas por RLS con has_role; esto solo
-- concede el privilegio SQL de tabla que faltaba). GRANT es idempotente.
--
-- Huecos detectados:
--  - carousel_images: tenía SELECT, UPDATE → faltaban INSERT y DELETE
--    (guardar el carrusel hace delete()+insert()).
--  - orders: tenía SELECT → faltaba UPDATE (cambiar el estado de un pedido).
-- ============================================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON public.carousel_images         TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.category_images         TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.product_image_overrides TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.product_order           TO authenticated;
GRANT SELECT, UPDATE                 ON public.orders                  TO authenticated;

-- ===================== 20260803120700_sales_ranking.sql =====================
-- ============================================================================
-- Ranking de ventas por producto para "Lo más vendido".
--
-- Los pedidos (orders/order_items) solo los puede leer el admin (RLS). Esta
-- función SECURITY DEFINER expone ÚNICAMENTE el conteo agregado de unidades
-- vendidas por producto (de pedidos pagados/enviados) — sin datos de clientes.
-- Se usa para ORDENAR el catálogo; no se muestran las cantidades al público.
-- ============================================================================
CREATE OR REPLACE FUNCTION public.product_sales_ranking()
RETURNS TABLE(product_id uuid, units bigint)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT pv.product_id, SUM(oi.quantity)::bigint AS units
  FROM public.order_items oi
  JOIN public.product_variants pv ON pv.id = oi.variant_id
  JOIN public.orders o ON o.id = oi.order_id
  WHERE o.status IN ('paid', 'fulfilled')
  GROUP BY pv.product_id
$$;

GRANT EXECUTE ON FUNCTION public.product_sales_ranking() TO anon, authenticated, service_role;

