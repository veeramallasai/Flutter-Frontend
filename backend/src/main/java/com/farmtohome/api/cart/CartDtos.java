package com.farmtohome.api.cart;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public final class CartDtos {
  private CartDtos() {}

  public record AddItemRequest(
      @NotBlank String productId,
      String itemId,
      String shoppingMode,
      String unit,
      @Min(1) @Max(99) int quantity) {}

  public record QuantityRequest(@Min(0) @Max(99) int quantity) {}
  public record CouponRequest(@NotBlank String couponCode) {}

  public record Item(
      String id,
      String productId,
      String name,
      String imageUrl,
      String category,
      String unit,
      String shoppingMode,
      BigDecimal unitPrice,
      BigDecimal mrp,
      int quantity,
      String farmerId) {}

  public record Cart(
      String userId,
      String shoppingMode,
      List<Item> items,
      String couponCode,
      BigDecimal couponDiscount,
      BigDecimal subtotal,
      BigDecimal productSavings,
      BigDecimal total,
      int itemCount,
      Instant updatedAt) {}
}
