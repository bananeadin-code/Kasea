
CREATE TABLE public.category_images (
  slug TEXT PRIMARY KEY,
  image_url TEXT NOT NULL,
  alt TEXT NOT NULL DEFAULT '',
  title TEXT NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.category_images TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.category_images TO authenticated;
GRANT ALL ON public.category_images TO service_role;

ALTER TABLE public.category_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Category images are viewable by everyone"
ON public.category_images FOR SELECT
USING (true);

CREATE POLICY "Admins can insert category images"
ON public.category_images FOR INSERT TO authenticated
WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update category images"
ON public.category_images FOR UPDATE TO authenticated
USING (public.has_role(auth.uid(), 'admin'))
WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete category images"
ON public.category_images FOR DELETE TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

CREATE TRIGGER update_category_images_updated_at
BEFORE UPDATE ON public.category_images
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
