CREATE TABLE categories (
  id varchar(80) PRIMARY KEY,
  name varchar(160) NOT NULL,
  description varchar(500) NOT NULL DEFAULT '',
  image_url varchar(500) NOT NULL DEFAULT '',
  icon_name varchar(100) NOT NULL DEFAULT '',
  sort_order integer NOT NULL DEFAULT 0,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_categories_active_sort ON categories(active, sort_order);

CREATE TABLE banners (
  id varchar(100) PRIMARY KEY,
  title varchar(200) NOT NULL,
  subtitle varchar(500) NOT NULL DEFAULT '',
  image_url varchar(500) NOT NULL DEFAULT '',
  action_label varchar(100) NOT NULL DEFAULT '',
  route varchar(300) NOT NULL DEFAULT '',
  priority integer NOT NULL DEFAULT 0,
  active boolean NOT NULL DEFAULT true,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT chk_banner_dates CHECK (ends_at IS NULL OR starts_at IS NULL OR ends_at >= starts_at)
);
CREATE INDEX idx_banners_visible ON banners(active, priority);

CREATE TABLE offers (
  id varchar(100) PRIMARY KEY,
  title varchar(200) NOT NULL,
  description varchar(500) NOT NULL DEFAULT '',
  code varchar(80) NOT NULL UNIQUE,
  discount_type varchar(30) NOT NULL,
  discount_value numeric(12,2) NOT NULL CHECK (discount_value >= 0),
  minimum_order numeric(12,2) NOT NULL DEFAULT 0 CHECK (minimum_order >= 0),
  maximum_discount numeric(12,2) NOT NULL DEFAULT 0 CHECK (maximum_discount >= 0),
  image_url varchar(500) NOT NULL DEFAULT '',
  active boolean NOT NULL DEFAULT true,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT chk_offer_type CHECK (discount_type IN ('percentage', 'fixed')),
  CONSTRAINT chk_offer_dates CHECK (ends_at IS NULL OR starts_at IS NULL OR ends_at >= starts_at)
);
CREATE INDEX idx_offers_active ON offers(active, starts_at, ends_at);

CREATE TABLE farmers (
  id varchar(120) PRIMARY KEY,
  name varchar(180) NOT NULL,
  farm_name varchar(220) NOT NULL,
  location varchar(250) NOT NULL DEFAULT '',
  image_url varchar(500) NOT NULL DEFAULT '',
  rating numeric(3,2) NOT NULL DEFAULT 0 CHECK (rating BETWEEN 0 AND 5),
  review_count integer NOT NULL DEFAULT 0 CHECK (review_count >= 0),
  verified boolean NOT NULL DEFAULT false,
  experience_years integer NOT NULL DEFAULT 0 CHECK (experience_years >= 0),
  speciality varchar(250) NOT NULL DEFAULT '',
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_farmers_active_rating ON farmers(active, verified DESC, rating DESC);

CREATE TABLE delivery_slots (
  id varchar(120) PRIMARY KEY,
  method varchar(40) NOT NULL,
  label varchar(160) NOT NULL,
  start_time time NOT NULL,
  end_time time NOT NULL,
  fee numeric(12,2) NOT NULL DEFAULT 0 CHECK (fee >= 0),
  available boolean NOT NULL DEFAULT true,
  capacity integer NOT NULL DEFAULT 0 CHECK (capacity >= 0),
  booked_count integer NOT NULL DEFAULT 0 CHECK (booked_count >= 0),
  slot_date date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT chk_delivery_method CHECK (method IN ('standard', 'express', 'scheduled', 'pickup')),
  CONSTRAINT chk_delivery_times CHECK (end_time > start_time),
  CONSTRAINT chk_delivery_capacity CHECK (capacity = 0 OR booked_count <= capacity)
);
CREATE INDEX idx_delivery_slots_lookup ON delivery_slots(method, slot_date, available, start_time);

CREATE TABLE favorites (
  id bigserial PRIMARY KEY,
  owner_uid varchar(160) NOT NULL,
  product_id varchar(120) NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uk_favorites_owner_product UNIQUE (owner_uid, product_id)
);
CREATE INDEX idx_favorites_owner ON favorites(owner_uid, created_at DESC);

CREATE TABLE reviews (
  id uuid PRIMARY KEY,
  product_id varchar(120) NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  owner_uid varchar(160) NOT NULL,
  user_name varchar(180) NOT NULL DEFAULT 'Verified customer',
  rating numeric(2,1) NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment varchar(1500) NOT NULL DEFAULT '',
  image_urls text NOT NULL DEFAULT '',
  verified_purchase boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uk_reviews_owner_product UNIQUE (owner_uid, product_id)
);
CREATE INDEX idx_reviews_product_created ON reviews(product_id, created_at DESC);

CREATE TABLE notifications (
  id uuid PRIMARY KEY,
  owner_uid varchar(160) NOT NULL,
  title varchar(220) NOT NULL,
  body varchar(1000) NOT NULL,
  notification_type varchar(60) NOT NULL DEFAULT 'general',
  image_url varchar(500) NOT NULL DEFAULT '',
  route varchar(300) NOT NULL DEFAULT '',
  data_json text NOT NULL DEFAULT '{}',
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_notifications_owner_created ON notifications(owner_uid, created_at DESC);
CREATE INDEX idx_notifications_unread ON notifications(owner_uid, is_read) WHERE NOT is_read;

CREATE TABLE support_tickets (
  id uuid PRIMARY KEY,
  owner_uid varchar(160) NOT NULL,
  subject varchar(220) NOT NULL,
  message varchar(2500) NOT NULL,
  category varchar(60) NOT NULL DEFAULT 'general',
  status varchar(40) NOT NULL DEFAULT 'open',
  priority varchar(40) NOT NULL DEFAULT 'normal',
  response varchar(2500) NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT chk_support_status CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
  CONSTRAINT chk_support_priority CHECK (priority IN ('low', 'normal', 'high', 'urgent'))
);
CREATE INDEX idx_support_owner_updated ON support_tickets(owner_uid, updated_at DESC);

CREATE TABLE device_tokens (
  id bigserial PRIMARY KEY,
  owner_uid varchar(160) NOT NULL,
  token varchar(1000) NOT NULL UNIQUE,
  platform varchar(30) NOT NULL DEFAULT 'unknown',
  device_name varchar(180) NOT NULL DEFAULT '',
  active boolean NOT NULL DEFAULT true,
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_device_tokens_owner ON device_tokens(owner_uid, active);

CREATE TABLE payment_events (
  id uuid PRIMARY KEY,
  payment_id uuid REFERENCES payments(id) ON DELETE SET NULL,
  owner_uid varchar(160) NOT NULL,
  gateway varchar(80) NOT NULL,
  gateway_event_id varchar(220) NOT NULL UNIQUE,
  event_type varchar(100) NOT NULL,
  signature_verified boolean NOT NULL DEFAULT false,
  payload_json text NOT NULL,
  processed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_payment_events_payment ON payment_events(payment_id, created_at DESC);

INSERT INTO categories (id, name, description, image_url, icon_name, sort_order)
VALUES
  ('vegetables', 'Vegetables', 'Farm-fresh vegetables selected every day', 'assets/images/categories/vegetables.png', 'eco', 0),
  ('fruits', 'Fruits', 'Naturally fresh seasonal and everyday fruits', 'assets/images/categories/fruits.png', 'nutrition', 1),
  ('dairy', 'Dairy', 'Fresh milk and trusted dairy essentials', 'assets/images/categories/dairy.png', 'local_drink', 2),
  ('seasonal', 'Seasonal', 'Limited seasonal harvests picked for you', 'assets/images/categories/seasonal.png', 'calendar_month', 3)
ON CONFLICT (id) DO NOTHING;

INSERT INTO banners (id, title, subtitle, image_url, action_label, route, priority)
VALUES
  ('fresh_vegetables', 'Fresh from local farms', 'Handpicked vegetables delivered with care', 'assets/images/categories/vegetables.png', 'Shop now', '/category-products?category=vegetables', 0),
  ('seasonal_fruits', 'Seasonal favourites', 'Naturally fresh fruits at honest prices', 'assets/images/categories/seasonal.png', 'Explore', '/category-products?category=seasonal', 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO offers (id, title, description, code, discount_type, discount_value, minimum_order, maximum_discount)
VALUES
  ('fresh10', 'Fresh 10% Off', 'Save on your first farm-fresh basket', 'FRESH10', 'percentage', 10, 299, 100),
  ('farm50', '₹50 Farm Savings', 'Flat savings on orders above ₹499', 'FARM50', 'fixed', 50, 499, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO farmers (id, name, farm_name, location, rating, review_count, verified, experience_years, speciality)
VALUES
  ('farmer_green_valley', 'Ravi Kumar', 'Green Valley Farms', 'Guntur, Andhra Pradesh', 4.8, 126, true, 14, 'Leafy vegetables'),
  ('farmer_sunrise', 'Lakshmi Devi', 'Sunrise Natural Farms', 'Vijayawada, Andhra Pradesh', 4.7, 98, true, 11, 'Seasonal fruits'),
  ('farmer_milky_way', 'Srinivas Reddy', 'Milky Way Dairy', 'Tenali, Andhra Pradesh', 4.9, 154, true, 18, 'Dairy products')
ON CONFLICT (id) DO NOTHING;

INSERT INTO delivery_slots (id, method, label, start_time, end_time, fee, capacity)
VALUES
  ('standard_morning', 'standard', 'Morning delivery', '08:00', '12:00', 35, 100),
  ('standard_evening', 'standard', 'Evening delivery', '16:00', '20:00', 35, 100),
  ('express_90', 'express', 'Express in 90 minutes', '09:00', '21:00', 69, 60),
  ('scheduled_morning', 'scheduled', '8 AM - 11 AM', '08:00', '11:00', 20, 80),
  ('scheduled_afternoon', 'scheduled', '1 PM - 4 PM', '13:00', '16:00', 20, 80),
  ('pickup_store', 'pickup', 'Store pickup', '08:00', '21:00', 0, 0)
ON CONFLICT (id) DO NOTHING;
