# Farm To Home Spring Boot API

Spring Boot REST backend for the Farm To Home Flutter application.

## Stack

- Java 17+
- Spring Boot 4.1
- PostgreSQL
- Flyway database migrations
- Firebase Admin token verification

## Included commerce APIs

- Products and search/filter
- Persistent cart and quantity updates
- Coupon validation
- Server-side price, stock, discount, delivery-fee, and total calculation
- Atomic COD order placement
- Orders, order details, cancellation, and reorder
- Automatic stock restoration on cancellation

The Flutter app sends the signed-in user's Firebase ID token as a Bearer token.
The backend verifies it before accessing any user cart or order.

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

