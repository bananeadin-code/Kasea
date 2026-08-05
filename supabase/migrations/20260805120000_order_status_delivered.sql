-- ============================================================================
-- Nuevo estado de pedido: 'delivered' (Entregado), separado de 'fulfilled'
-- (Enviado). Así el admin marca "Enviado" y "Entregado" por separado, y el
-- cliente ve ese detalle en su historial.
--
-- Flujo de estados: pending → paid → fulfilled (enviado) → delivered (entregado)
--                   (cancelled / refunded en cualquier momento)
-- ============================================================================
ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_status_check;

ALTER TABLE public.orders
  ADD CONSTRAINT orders_status_check
  CHECK (status IN ('pending', 'paid', 'fulfilled', 'delivered', 'cancelled', 'refunded'));
