CREATE TABLE IF NOT EXISTS delivery_partners (
  id uuid PRIMARY KEY,
  name varchar(160) NOT NULL,
  phone varchar(30),
  photo_url text,
  vehicle_number varchar(80),
  rating numeric(2,1) NOT NULL DEFAULT 0,
  review_count integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS delivery_partner_id uuid;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_orders_delivery_partner'
  ) THEN
    ALTER TABLE orders
      ADD CONSTRAINT fk_orders_delivery_partner
      FOREIGN KEY (delivery_partner_id)
      REFERENCES delivery_partners(id)
      ON DELETE SET NULL;
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS delivery_partner_reviews (
  id uuid PRIMARY KEY,
  order_id uuid NOT NULL,
  customer_uid varchar(160) NOT NULL,
  delivery_partner_id uuid NOT NULL,
  rating numeric(2,1) NOT NULL,
  comment text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT fk_delivery_partner_review_order
    FOREIGN KEY (order_id)
    REFERENCES orders(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_delivery_partner_review_customer
    FOREIGN KEY (customer_uid)
    REFERENCES app_users(firebase_uid)
    ON DELETE CASCADE,

  CONSTRAINT fk_delivery_partner_review_partner
    FOREIGN KEY (delivery_partner_id)
    REFERENCES delivery_partners(id)
    ON DELETE CASCADE,

  CONSTRAINT chk_delivery_partner_rating
    CHECK (rating >= 1 AND rating <= 5),

  CONSTRAINT uq_delivery_partner_review_order_customer
    UNIQUE (order_id, customer_uid)
);

CREATE INDEX IF NOT EXISTS idx_orders_delivery_partner_id
  ON orders(delivery_partner_id);

CREATE INDEX IF NOT EXISTS idx_delivery_partner_reviews_partner
  ON delivery_partner_reviews(delivery_partner_id);

CREATE INDEX IF NOT EXISTS idx_delivery_partner_reviews_customer
  ON delivery_partner_reviews(customer_uid);