
-- Roles enum + user_roles table + has_role function
CREATE TYPE public.app_role AS ENUM ('admin');

CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role public.app_role NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);

GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own roles"
  ON public.user_roles FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role public.app_role)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;

-- Carousel images table
CREATE TABLE public.carousel_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  image_key TEXT NOT NULL UNIQUE,
  alt TEXT NOT NULL DEFAULT '',
  position INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.carousel_images TO anon;
GRANT SELECT, UPDATE ON public.carousel_images TO authenticated;
GRANT ALL ON public.carousel_images TO service_role;

ALTER TABLE public.carousel_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Carousel images are viewable by everyone"
  ON public.carousel_images FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can update carousel images"
  ON public.carousel_images FOR UPDATE
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

-- Seed initial carousel data (9 uploaded images)
INSERT INTO public.carousel_images (image_key, alt, position) VALUES
  ('carousel-01', 'Funda Kasea lila con rayas y motivo veraniego', 1),
  ('carousel-02', 'Funda Kasea turquesa con rayas y detalle gráfico rojo', 2),
  ('carousel-03', 'Funda Kasea con rayas celestes y motivo de langosta', 3),
  ('carousel-04', 'Funda Kasea de lunares con ilustración femenina', 4),
  ('carousel-05', 'Funda Kasea de rayas azul marino con perro y taza', 5),
  ('carousel-06', 'Funda Kasea rosa con lunares y gato ilustrado', 6),
  ('carousel-07', 'Funda Kasea rosa con espiral y gato negro', 7),
  ('carousel-08', 'Funda Kasea de lunares con perro y pañuelo animal print', 8),
  ('carousel-09', 'Funda Kasea rosa con corazones y gato', 9);
