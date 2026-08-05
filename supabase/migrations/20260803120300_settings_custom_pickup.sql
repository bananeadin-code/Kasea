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
