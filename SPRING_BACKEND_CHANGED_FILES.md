# Spring Backend Integration — Changed Files

## Flutter integration

- `lib/core/config/backend_config.dart`
- `lib/core/network/api_client.dart`
- `lib/core/errors/network_exception.dart`
- `lib/data/remote/product_remote_source.dart`
- `lib/data/repositories/product_repository.dart`
- `lib/data/remote/cart_remote_source.dart`
- `lib/providers/cart_provider.dart`
- `lib/data/remote/order_remote_source.dart`
- `lib/data/repositories/order_repository.dart`
- `lib/providers/orders_provider.dart`
- `lib/core/services/order_backend_service.dart`
- `lib/features/payment/payment_screen.dart`
- `lib/features/orders/order_details_screen.dart`
- `lib/features/home/home_screen.dart`
- `lib/core/services/storage_service.dart`
- `lib/core/services/secure_storage_service.dart`
- `lib/core/services/analytics_service.dart`
- `pubspec.yaml`

## New backend

- Complete `backend/` folder
- PostgreSQL migrations: `V1__schema.sql`, `V2__coupons.sql`, `V3__product_catalog.sql`
- Spring Boot product, cart, coupon, order, payment, security, exception, and config classes
- `BACKEND_SETUP_TELUGU.md`

The ZIP overlays only these source areas. It does not delete or replace the existing
`assets`, `android`, `ios`, or Firebase platform configuration.
