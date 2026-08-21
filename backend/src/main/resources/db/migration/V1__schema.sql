CREATE TABLE products (
  id varchar(120) PRIMARY KEY,
  name varchar(255) NOT NULL,
  english_name varchar(160) NOT NULL,
  telugu_name varchar(160) NOT NULL,
  description varchar(800) NOT NULL,
  category varchar(80) NOT NULL,
  image_url varchar(500) NOT NULL,
  unit varchar(80) NOT NULL,
  price numeric(12,2) NOT NULL CHECK (price > 0),
  mrp numeric(12,2) NOT NULL CHECK (mrp >= price),
  shop_unit varchar(80) NOT NULL,
  shop_price numeric(12,2) NOT NULL CHECK (shop_price > 0),
  shop_mrp numeric(12,2) NOT NULL CHECK (shop_mrp >= shop_price),
  stock_quantity integer NOT NULL CHECK (stock_quantity >= 0),
  active boolean NOT NULL DEFAULT true,
  fresh boolean NOT NULL DEFAULT true,
  rating numeric(3,2) NOT NULL DEFAULT 0,
  review_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_products_category_active ON products(category, active);

CREATE TABLE coupons (
  id varchar(80) PRIMARY KEY,
  code varchar(80) NOT NULL UNIQUE,
  title varchar(180) NOT NULL,
  discount_type varchar(30) NOT NULL,
  discount_value numeric(12,2) NOT NULL,
  minimum_order numeric(12,2) NOT NULL DEFAULT 0,
  maximum_discount numeric(12,2) NOT NULL DEFAULT 0,
  active boolean NOT NULL DEFAULT true
);

CREATE TABLE carts (
  owner_uid varchar(160) PRIMARY KEY,
  shopping_mode varchar(20) NOT NULL DEFAULT 'home',
  coupon_code varchar(80) NOT NULL DEFAULT '',
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE cart_items (
  id bigserial PRIMARY KEY,
  owner_uid varchar(160) NOT NULL REFERENCES carts(owner_uid) ON DELETE CASCADE,
  item_key varchar(180) NOT NULL,
  product_id varchar(120) NOT NULL REFERENCES products(id),
  shopping_mode varchar(20) NOT NULL,
  unit varchar(80) NOT NULL,
  quantity integer NOT NULL CHECK (quantity BETWEEN 1 AND 99),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uk_cart_item_owner_key UNIQUE (owner_uid, item_key)
);
CREATE INDEX idx_cart_items_owner ON cart_items(owner_uid);

CREATE TABLE orders (
  id uuid PRIMARY KEY,
  order_number varchar(60) NOT NULL UNIQUE,
  owner_uid varchar(160) NOT NULL,
  shopping_mode varchar(20) NOT NULL,
  status varchar(40) NOT NULL,
  payment_status varchar(40) NOT NULL,
  payment_method varchar(60) NOT NULL,
  payment_id uuid NOT NULL,
  subtotal numeric(12,2) NOT NULL,
  mrp_total numeric(12,2) NOT NULL,
  product_savings numeric(12,2) NOT NULL,
  coupon_code varchar(80) NOT NULL DEFAULT '',
  coupon_discount numeric(12,2) NOT NULL DEFAULT 0,
  delivery_fee numeric(12,2) NOT NULL DEFAULT 0,
  total_amount numeric(12,2) NOT NULL,
  item_count integer NOT NULL,
  address_id varchar(160) NOT NULL,
  address_json text NOT NULL,
  delivery_method varchar(40) NOT NULL,
  delivery_date date,
  delivery_slot varchar(160) NOT NULL,
  cancellation_reason varchar(500) NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_orders_owner_created ON orders(owner_uid, created_at DESC);

CREATE TABLE order_items (
  id bigserial PRIMARY KEY,
  order_id uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  cart_item_id varchar(180) NOT NULL,
  product_id varchar(120) NOT NULL,
  name varchar(255) NOT NULL,
  image_url varchar(500) NOT NULL,
  category varchar(80) NOT NULL,
  unit varchar(80) NOT NULL,
  shopping_mode varchar(20) NOT NULL,
  unit_price numeric(12,2) NOT NULL,
  mrp numeric(12,2) NOT NULL,
  quantity integer NOT NULL,
  line_total numeric(12,2) NOT NULL
);
CREATE INDEX idx_order_items_order ON order_items(order_id);

CREATE TABLE payments (
  id uuid PRIMARY KEY,
  order_id uuid NOT NULL UNIQUE REFERENCES orders(id) ON DELETE CASCADE,
  owner_uid varchar(160) NOT NULL,
  method varchar(60) NOT NULL,
  status varchar(40) NOT NULL,
  total_amount numeric(12,2) NOT NULL,
  transaction_id varchar(180) NOT NULL DEFAULT '',
  gateway varchar(80) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_payments_owner ON payments(owner_uid, created_at DESC);
