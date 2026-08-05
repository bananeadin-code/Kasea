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
