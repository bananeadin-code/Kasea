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
