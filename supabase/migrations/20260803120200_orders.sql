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
