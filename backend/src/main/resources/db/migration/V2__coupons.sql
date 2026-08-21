INSERT INTO coupons (id, code, title, discount_type, discount_value, minimum_order, maximum_discount, active)
VALUES
  ('fresh10', 'FRESH10', '10% fresh savings', 'percentage', 10, 299, 100, true),
  ('farm50', 'FARM50', 'Flat ₹50 off', 'fixed', 50, 499, 50, true)
ON CONFLICT (id) DO NOTHING;
