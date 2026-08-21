# Farm To Home v9 database

Spring Boot starts Flyway automatically. Migrations `V1` through `V7` create the schema.

## App tables (21)

1. `products`
2. `coupons`
3. `carts`
4. `cart_items`
5. `orders`
6. `order_items`
7. `payments`
8. `app_users`
9. `addresses`
10. `categories`
11. `banners`
12. `offers`
13. `farmers`
14. `delivery_slots`
15. `favorites`
16. `reviews`
17. `notifications`
18. `notification_preferences`
19. `support_tickets`
20. `device_tokens`
21. `payment_events`

PostgreSQL also shows `flyway_schema_history`, which records applied migrations. Therefore pgAdmin shows 22 tables in `public` after v9 starts successfully.

Open pgAdmin Query Tool and run `backend/database_verification.sql` to list every table, migration, and important row count.

Firebase Authentication remains responsible for Google, email/password, phone OTP, email verification, and ID tokens. `app_users` stores the synchronized application profile. Online payment capture needs real merchant gateway keys and verified webhooks; `payment_events` is ready for those verified events. Cash on Delivery is stored in `orders` and `payments` now.
