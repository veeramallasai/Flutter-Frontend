CREATE TABLE addresses (
  id uuid PRIMARY KEY,
  owner_uid varchar(160) NOT NULL REFERENCES app_users(firebase_uid) ON DELETE CASCADE,
  full_name varchar(160) NOT NULL,
  phone varchar(32) NOT NULL,
  address_line1 varchar(300) NOT NULL,
  address_line2 varchar(300) NOT NULL DEFAULT '',
  city varchar(120) NOT NULL,
  state varchar(120) NOT NULL,
  postal_code varchar(12) NOT NULL,
  landmark varchar(200) NOT NULL DEFAULT '',
  address_type varchar(20) NOT NULL,
  is_default boolean NOT NULL DEFAULT false,
  latitude numeric(10,7) NOT NULL DEFAULT 0,
  longitude numeric(10,7) NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT chk_addresses_type CHECK (address_type IN ('Home', 'Work', 'Other')),
  CONSTRAINT chk_addresses_postal_code CHECK (postal_code ~ '^[0-9]{6}$'),
  CONSTRAINT chk_addresses_latitude CHECK (latitude BETWEEN -90 AND 90),
  CONSTRAINT chk_addresses_longitude CHECK (longitude BETWEEN -180 AND 180)
);

CREATE INDEX idx_addresses_owner_created
  ON addresses(owner_uid, created_at DESC);

CREATE UNIQUE INDEX uk_addresses_one_default_per_owner
  ON addresses(owner_uid)
  WHERE is_default = true;
