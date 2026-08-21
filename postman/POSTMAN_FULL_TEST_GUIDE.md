# Farm To Home Backend v9 - Full Postman Test

## What this tests

This collection runs 54 requests covering every Spring API group: health/security, Firebase user sync, products, saved addresses, cart, coupons, COD orders, categories, banners, offers, farmers, delivery slots, favorites, reviews, notifications, preferences, support tickets, devices, and cleanup.

Postman tests backend APIs. The included PowerShell verifier separately runs Flutter analyze/tests and backend tests.

## Import

1. Open Postman.
2. Click Import (Ctrl+O).
3. Import both JSON files in this folder.
4. If Collection exists appears, keep Apply to all checked and click Replace.
5. Select environment: Farm To Home - Local Full Test.

## Token

Paste a valid Firebase ID token into the environment variable firebaseToken. Never send that token in chat or store it in Git.

## Run all

1. Keep Spring Boot running on http://localhost:8080.
2. Open Collections.
3. Open Farm To Home Backend v9 - Complete Production API Flow.
4. Click Run collection.
5. Keep the displayed request order.
6. Click Run.

Expected result: all tests pass. The runner creates dedicated test data and cleans favorites, review, device, cart, and address data. The cancelled COD test order and closed support ticket remain as audit records.
