-- ============================================================================
-- Correo de avisos al administrador (editable en el panel → Ajustes).
-- Al confirmarse un pedido, además del correo al cliente, se envía un aviso a
-- esta dirección con el resumen y, si es funda personalizada, el diseño.
-- ============================================================================
ALTER TABLE public.shop_settings ADD COLUMN IF NOT EXISTS notify_email text;
