CREATE TABLE email_verification_otps (
  id bigserial PRIMARY KEY,
  firebase_uid varchar(160) NOT NULL REFERENCES app_users(firebase_uid) ON DELETE CASCADE,
  email varchar(320) NOT NULL,
  otp_hash varchar(256) NOT NULL,
  purpose varchar(50) NOT NULL,
  expires_at timestamptz NOT NULL,
  verified_at timestamptz,
  attempts integer NOT NULL DEFAULT 0,
  resend_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_email_verification_otps_uid_email
  ON email_verification_otps(firebase_uid, email);

CREATE INDEX idx_email_verification_otps_expires_at
  ON email_verification_otps(expires_at);
