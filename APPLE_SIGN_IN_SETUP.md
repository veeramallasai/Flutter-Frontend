# Sign in with Apple setup

The app uses Apple's authorization SDK through `sign_in_with_apple`. The
backend validates the Apple identity-token signature, issuer, audience, expiry,
and SHA-256 nonce before creating a session.

## Apple Developer configuration

1. Enable **Sign in with Apple** for the App ID matching
   `com.example.farmToHomeApp`.
2. Create a Services ID for web/Android authentication.
3. Configure the Railway frontend domain and the exact callback URL as a Return
   URL on that Services ID. Apple requires HTTPS outside local native testing.
4. In Xcode, select the Runner target and confirm the **Sign in with Apple**
   capability and provisioning profile.

## Flutter variables

For web, use the HTTPS frontend return URL registered with Apple. For Android,
use the deployed backend relay endpoint
`https://YOUR-BACKEND/api/v1/auth/apple/callback`:

```powershell
flutter run -d chrome `
  --dart-define=APPLE_SERVICE_ID=your.apple.service.id `
  --dart-define=APPLE_REDIRECT_URI=https://your-domain.example/auth/apple/callback
```

Set the same values as Railway frontend build variables. Native iOS/macOS uses
the application entitlement and does not require web authentication options.
The Android manifest already registers the plugin callback activity.

## Backend variables

Set `APPLE_CLIENT_IDS` to the comma-separated bundle ID and Services ID. Also
set a random `JWT_SECRET` containing at least 32 bytes. Never store an Apple
private key or JWT secret in the repository.