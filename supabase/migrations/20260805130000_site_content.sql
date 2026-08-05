-- ============================================================================
-- Contenido editable de la web (textos por temporada) — clave/valor.
--
-- Permite cambiar títulos y descripciones destacados (barra de anuncio, hero…)
-- desde el panel de administración, sin tocar el código ni depender de Lovable.
-- Lectura pública; escritura solo admin.
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.site_content (
  key        text PRIMARY KEY,
  value      text NOT NULL DEFAULT '',
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Valores por defecto (los mismos textos que hay hoy en la web).
INSERT INTO public.site_content (key, value) VALUES
  ('announcement_text', 'Envío gratuito en pedidos superiores a 55€'),
  ('hero_title_line1',  'TU MOVIL MERECE'),
  ('hero_title_line2',  'una funda única'),
  ('hero_intro',        'En KASEA diseñamos exclusivamente fundas para iPhone. Elige tu modelo y, si no encuentras tu estilo, te lo creamos.'),
  ('hero_cta',          'Lo más vendido')
ON CONFLICT (key) DO NOTHING;

-- Permisos: público lee; admin (authenticated) inserta/actualiza; service_role todo.
GRANT SELECT                 ON public.site_content TO anon;
GRANT SELECT, INSERT, UPDATE ON public.site_content TO authenticated;
GRANT ALL                    ON public.site_content TO service_role;

ALTER TABLE public.site_content ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can read site content"
  ON public.site_content FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins manage site content"
  ON public.site_content FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE TRIGGER update_site_content_updated_at
  BEFORE UPDATE ON public.site_content
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
