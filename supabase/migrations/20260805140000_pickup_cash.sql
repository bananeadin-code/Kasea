-- ============================================================================
-- Pago en EFECTIVO para recogida en tienda.
--
--   orders.payment_method  'card' (tarjeta, vía Stripe) | 'cash' (efectivo en tienda)
--   orders.payment_status  'paid' (cobrado) | 'pending' (pendiente de cobro)
--
-- El pago (payment_status) es INDEPENDIENTE del estado de preparación/entrega
-- (status). Un pedido en efectivo se crea con payment_status='pending' y el
-- admin lo marca 'paid' cuando cobra en tienda.
--
-- process_paid_order() v3: acepta method/status de pago (por defecto card/paid,
-- así el webhook de Stripe sigue funcionando igual sin pasarlos).
-- ============================================================================
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS payment_method text NOT NULL DEFAULT 'card'
    CHECK (payment_method IN ('card', 'cash')),
  ADD COLUMN IF NOT EXISTS payment_status text NOT NULL DEFAULT 'paid'
    CHECK (payment_status IN ('paid', 'pending'));

-- Reemplazo de la firma anterior (v2, 12 args) por la nueva (v3, 14 args).
DROP FUNCTION IF EXISTS public.process_paid_order(
  text, text, text, text, text, jsonb, text, text, integer, integer, integer, jsonb
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
  _items            jsonb,
  _payment_method   text DEFAULT 'card',
  _payment_status   text DEFAULT 'paid'
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
  -- Idempotencia por sesión/referencia.
  SELECT id INTO _existing FROM public.orders WHERE stripe_session_id = _session_id;
  IF _existing IS NOT NULL THEN
    RETURN jsonb_build_object('order_id', _existing, 'already_processed', true);
  END IF;

  INSERT INTO public.orders (
    stripe_session_id, stripe_payment_intent, email, customer_name, phone,
    shipping_address, delivery_method, currency,
    subtotal_cents, shipping_cents, total_cents, status,
    payment_method, payment_status
  ) VALUES (
    _session_id, _payment_intent, _email, _name, _phone,
    _address, COALESCE(NULLIF(_delivery_method, ''), 'delivery'), COALESCE(_currency, 'EUR'),
    COALESCE(_subtotal_cents, 0), COALESCE(_shipping_cents, 0), COALESCE(_total_cents, 0),
    'paid',
    COALESCE(NULLIF(_payment_method, ''), 'card'),
    COALESCE(NULLIF(_payment_status, ''), 'paid')
  )
  RETURNING id INTO _order_id;

  FOR _item IN SELECT * FROM jsonb_array_elements(COALESCE(_items, '[]'::jsonb))
  LOOP
    _qty := COALESCE((_item->>'quantity')::int, 1);

    _is_custom := COALESCE((
      SELECT p.is_custom
      FROM public.product_variants v
      JOIN public.products p ON p.id = v.product_id
      WHERE v.id = NULLIF(_item->>'variant_id', '')::uuid
    ), false);

    IF NOT _is_custom THEN
      -- Descuento ATÓMICO y CONDICIONAL (nunca negativo, sin sobreventa). Se
      -- reserva el stock al crear el pedido, también en efectivo.
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

REVOKE ALL ON FUNCTION public.process_paid_order(text, text, text, text, text, jsonb, text, text, integer, integer, integer, jsonb, text, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.process_paid_order(text, text, text, text, text, jsonb, text, text, integer, integer, integer, jsonb, text, text) TO service_role;
