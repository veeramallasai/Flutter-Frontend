CREATE TABLE notification_preferences (
  owner_uid varchar(160) PRIMARY KEY,
  order_updates boolean NOT NULL DEFAULT true,
  offers boolean NOT NULL DEFAULT true,
  updated_at timestamptz NOT NULL DEFAULT now()
);

