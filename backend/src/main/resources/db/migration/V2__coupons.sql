DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'coupons' AND column_name = 'id' AND (data_type = 'uuid' OR data_type LIKE '%uuid%')
  ) THEN
    ALTER TABLE coupons ALTER COLUMN id TYPE varchar(80) USING id::text;
  END IF;
END $$;

INSERT INTO coupons (id, code, title, discount_type, discount_value, minimum_order, maximum_discount, active)
VALUES
  ('fresh10', 'FRESH10', '10% fresh savings', 'percentage', 10, 299, 100, true),
  ('farm50', 'FARM50', 'Flat ₹50 off', 'fixed', 50, 499, 50, true)
ON CONFLICT (id) DO NOTHING;

