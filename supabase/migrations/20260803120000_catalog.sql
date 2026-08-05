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
