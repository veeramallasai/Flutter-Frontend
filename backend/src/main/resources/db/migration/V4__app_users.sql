CREATE TABLE app_users (
  firebase_uid varchar(160) PRIMARY KEY,
  first_name varchar(100) NOT NULL DEFAULT '',
  last_name varchar(100) NOT NULL DEFAULT '',
  display_name varchar(220) NOT NULL DEFAULT '',
  email varchar(320) NOT NULL DEFAULT '',
  phone_number varchar(32) NOT NULL DEFAULT '',
  photo_url varchar(1000) NOT NULL DEFAULT '',
  shopping_mode varchar(20) NOT NULL DEFAULT 'home',
  account_type varchar(40) NOT NULL DEFAULT 'customer',
  auth_provider varchar(80) NOT NULL DEFAULT 'password',
  email_verified boolean NOT NULL DEFAULT false,
  phone_verified boolean NOT NULL DEFAULT false,
  active boolean NOT NULL DEFAULT true,
  last_login_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT chk_app_users_shopping_mode
    CHECK (shopping_mode IN ('home', 'shop')),
  CONSTRAINT chk_app_users_account_type
    CHECK (account_type IN ('customer', 'shop_owner'))
);

CREATE UNIQUE INDEX uk_app_users_email
  ON app_users (lower(email))
  WHERE email <> '';

CREATE UNIQUE INDEX uk_app_users_phone
  ON app_users (phone_number)
  WHERE phone_number <> '' AND phone_verified;

CREATE INDEX idx_app_users_last_login
  ON app_users (last_login_at DESC);
