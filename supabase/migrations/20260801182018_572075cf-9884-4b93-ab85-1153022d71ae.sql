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

DROP POLICY "Admins can update carousel images" ON public.carousel_images;
DROP POLICY "Admins can insert carousel images" ON public.carousel_images;
DROP POLICY "Admins can delete carousel images" ON public.carousel_images;
CREATE POLICY "Admins can update carousel images" ON public.carousel_images FOR UPDATE TO authenticated USING (private.has_role(auth.uid(), 'admin')) WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert carousel images" ON public.carousel_images FOR INSERT TO authenticated WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete carousel images" ON public.carousel_images FOR DELETE TO authenticated USING (private.has_role(auth.uid(), 'admin'));

DROP POLICY "Admins can update category images" ON public.category_images;
DROP POLICY "Admins can insert category images" ON public.category_images;
DROP POLICY "Admins can delete category images" ON public.category_images;
CREATE POLICY "Admins can update category images" ON public.category_images FOR UPDATE TO authenticated USING (private.has_role(auth.uid(), 'admin')) WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert category images" ON public.category_images FOR INSERT TO authenticated WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete category images" ON public.category_images FOR DELETE TO authenticated USING (private.has_role(auth.uid(), 'admin'));

DROP POLICY "Admins can update product image overrides" ON public.product_image_overrides;
DROP POLICY "Admins can insert product image overrides" ON public.product_image_overrides;
DROP POLICY "Admins can delete product image overrides" ON public.product_image_overrides;
CREATE POLICY "Admins can update product image overrides" ON public.product_image_overrides FOR UPDATE TO authenticated USING (private.has_role(auth.uid(), 'admin')) WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert product image overrides" ON public.product_image_overrides FOR INSERT TO authenticated WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete product image overrides" ON public.product_image_overrides FOR DELETE TO authenticated USING (private.has_role(auth.uid(), 'admin'));

DROP POLICY "Admins can update product order" ON public.product_order;
DROP POLICY "Admins can insert product order" ON public.product_order;
DROP POLICY "Admins can delete product order" ON public.product_order;
CREATE POLICY "Admins can update product order" ON public.product_order FOR UPDATE TO authenticated USING (private.has_role(auth.uid(), 'admin')) WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert product order" ON public.product_order FOR INSERT TO authenticated WITH CHECK (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete product order" ON public.product_order FOR DELETE TO authenticated USING (private.has_role(auth.uid(), 'admin'));

DROP POLICY "Admins can delete user roles" ON public.user_roles;
DROP POLICY "Admins can insert user roles" ON public.user_roles;
CREATE POLICY "Admins can delete user roles" ON public.user_roles FOR DELETE TO authenticated USING (private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert user roles" ON public.user_roles FOR INSERT TO authenticated WITH CHECK (private.has_role(auth.uid(), 'admin'));

DROP POLICY "Admins can upload to site-images" ON storage.objects;
DROP POLICY "Admins can update site-images" ON storage.objects;
DROP POLICY "Admins can delete site-images" ON storage.objects;
CREATE POLICY "Admins can upload to site-images" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'site-images' AND private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can update site-images" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'site-images' AND private.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete site-images" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'site-images' AND private.has_role(auth.uid(), 'admin'));

DROP FUNCTION IF EXISTS public.has_role(uuid, public.app_role);