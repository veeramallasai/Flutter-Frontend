# Farm To Home v9 — consistency audit

## Audited project scope

- Flutter/Dart source files: **280**
- Spring Boot Java source/test files: **44**
- Named Flutter routes: **35**
- PostgreSQL application tables: **21**
- Flyway history table: **1**
- Total tables visible in `public`: **22**
- Flyway migrations: **7** (`V1` through `V7`)
- Seeded products: **111**
- Product groups: **48 vegetables, 50 fruits, 13 dairy**
- Postman requests: **54** in **8** folders
- Empty Dart/Java source files: **0**

## Database tables

`products`, `coupons`, `carts`, `cart_items`, `orders`, `order_items`,
`payments`, `app_users`, `addresses`, `categories`, `banners`, `offers`,
`farmers`, `delivery_slots`, `favorites`, `reviews`, `notifications`,
`notification_preferences`, `support_tickets`, `device_tokens`, and
`payment_events`.

PostgreSQL also creates `flyway_schema_history` to record applied migrations.

## Completed runtime flow

1. Firebase authenticates Google, email/password, phone OTP, and supplies a signed ID token.
2. Spring Boot verifies the Firebase token for every `/api/**` request.
3. The signed-in user is synchronized to PostgreSQL `app_users`.
4. Products, bilingual names, images, prices, stock, cart, coupon, addresses,
   COD orders, order items, payments, notifications, favorites, reviews,
   delivery slots, farmers, support tickets, and device tokens use backend APIs.
5. COD checkout validates the cart/address, stores order snapshots, reduces stock,
   creates the pending payment row, clears the cart, and creates a notification.
6. Cancellation restores stock and updates order/payment state.

## Production boundary

COD is connected and stored in PostgreSQL. Online payment choices are shown as
`COMING SOON` and remain disabled until a real merchant account, production
gateway keys, signature validation, and verified webhooks are supplied. No fake
payment-success path is enabled.

## Verification

`tools/static_audit.py` validates source delimiters, internal imports, route
coverage, `pubspec.yaml`, `pom.xml`, migration order, all expected tables,
111 unique bilingual product records and asset paths, Postman JSON/request count,
and production placeholder text.

On the Windows development machine, run `verify_everything.ps1` for the real
Maven build/tests, Flutter analyzer/tests, PostgreSQL runtime health, migration
coverage, and Postman package validation. The authenticated 54-request Newman
suite runs when a current Firebase ID token is supplied.
