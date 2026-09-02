DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_carts_owner_user'
  ) THEN
    ALTER TABLE carts
      ADD CONSTRAINT fk_carts_owner_user
      FOREIGN KEY (owner_uid)
      REFERENCES app_users(firebase_uid)
      ON DELETE CASCADE
      NOT VALID;
  END IF;
END $$;