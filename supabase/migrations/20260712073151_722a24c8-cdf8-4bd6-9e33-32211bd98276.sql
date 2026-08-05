CREATE TABLE public.product_order (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_handle text NOT NULL UNIQUE,
  position integer NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT ON public.product_order TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.product_order TO authenticated;
GRANT ALL ON public.product_order TO service_role;

ALTER TABLE public.product_order ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Product order is viewable by everyone"
  ON public.product_order FOR SELECT
  TO anon, authenticated USING (true);

CREATE POLICY "Admins can insert product order"
  ON public.product_order FOR INSERT
  TO authenticated WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update product order"
  ON public.product_order FOR UPDATE
  TO authenticated USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete product order"
  ON public.product_order FOR DELETE
  TO authenticated USING (has_role(auth.uid(), 'admin'::app_role));

CREATE TRIGGER update_product_order_updated_at
  BEFORE UPDATE ON public.product_order
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();