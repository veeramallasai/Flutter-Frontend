# Farm To Home Spring Boot API

Spring Boot REST backend for the Farm To Home Flutter application.

## Stack

- Java 17+
- Spring Boot 4.1
- PostgreSQL
- Flyway database migrations
- Google and Apple identity-token verification
- Signed application JWT sessions

## Included commerce APIs

- Products and search/filter
- Persistent cart and quantity updates
- Coupon validation
- Server-side price, stock, discount, delivery-fee, and total calculation
- Atomic COD order placement
- Orders, order details, cancellation, and reorder
- Automatic stock restoration on cancellation

The Flutter app sends a Google or Apple identity token to the matching auth
endpoint. The backend verifies its signature, issuer, audience, expiry, email,
and Apple nonce before creating or loading the user. It then returns a signed
application JWT used as the Bearer token for protected APIs.

For Railway, configure `GOOGLE_CLIENT_IDS`, `APPLE_CLIENT_IDS`, `JWT_SECRET`,
`JWT_ISSUER`, and `CORS_ORIGINS`. `GOOGLE_CLIENT_IDS` and `APPLE_CLIENT_IDS`
accept comma-separated IDs for web and native apps. `JWT_SECRET` must contain
at least 32 random bytes and must be the same across all backend instances.

## Run

Create a PostgreSQL database named `farm_to_home`, configure the environment
variables shown in `.env.example`, and run:

```powershell
mvn spring-boot:run
```

Flyway creates the tables and seeds 111 products and coupons automatically.
Health check: `http://localhost:8080/actuator/health`

For the complete Windows and pgAdmin instructions, read
`../BACKEND_SETUP_TELUGU.md`.

