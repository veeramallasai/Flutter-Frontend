package com.farmtohome.api.migration;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

class MigrationCoverageTest {
  @Test
  void productionSchemaContainsEveryRequiredAppTable() throws IOException {
    String migrations = String.join("\n",
        resource("/db/migration/V1__schema.sql"),
        resource("/db/migration/V2__coupons.sql"),
        resource("/db/migration/V4__app_users.sql"),
        resource("/db/migration/V5__addresses.sql"),
        resource("/db/migration/V6__platform_modules.sql"),
        resource("/db/migration/V7__notification_preferences.sql"),
        resource("/db/migration/V14__cart_customer_foreign_key.sql"));

    for (String table : new String[] {
        "products", "coupons", "carts", "cart_items", "orders",
        "order_items", "payments", "app_users", "addresses", "categories",
        "banners", "offers", "farmers", "delivery_slots", "favorites",
        "reviews", "notifications", "notification_preferences",
        "support_tickets", "device_tokens", "payment_events"
    }) {
      assertThat(migrations.toLowerCase())
          .as("migration for table %s", table)
          .contains("table " + table);
    }
  }

  private String resource(String path) throws IOException {
    try (var stream = getClass().getResourceAsStream(path)) {
      assertThat(stream).as("resource %s", path).isNotNull();
      return new String(stream.readAllBytes(), StandardCharsets.UTF_8);
    }
  }
}
