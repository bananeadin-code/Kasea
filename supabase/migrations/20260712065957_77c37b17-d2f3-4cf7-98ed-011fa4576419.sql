
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
