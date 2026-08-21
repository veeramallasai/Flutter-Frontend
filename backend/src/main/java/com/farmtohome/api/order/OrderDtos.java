package com.farmtohome.api.order;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public final class OrderDtos {
  private OrderDtos() {}

  public record PlaceOrderRequest(
      String shoppingMode,
      String paymentMethod,
      @NotBlank String addressId,
      @NotEmpty Map<String, Object> address,
      String deliveryMethod,
      LocalDate deliveryDate,
      String deliverySlot,
      String couponCode) {}

  public record CancelRequest(String reason) {}

  public record Item(
      String id,
      String cartItemId,
      String productId,
      String name,
      String imageUrl,
      String category,
      String unit,
      String shoppingMode,
      BigDecimal unitPrice,
      BigDecimal mrp,
      int quantity,
      BigDecimal lineTotal,
      boolean inStock) {}

  public record Order(
      String id,
      String orderId,
      String orderNumber,
      String userId,
      String shoppingMode,
      String status,
      String paymentStatus,
      String paymentMethod,
      String paymentId,
      String transactionId,
      List<Item> items,
      int itemCount,
      BigDecimal subtotal,
      BigDecimal mrpTotal,
      BigDecimal productSavings,
      String couponCode,
      BigDecimal couponDiscount,
      BigDecimal deliveryFee,
      BigDecimal totalAmount,
      String addressId,
      Map<String, Object> address,
      String deliveryMethod,
      LocalDate deliveryDate,
      String deliverySlot,
      String cancellationReason,
      List<Map<String, Object>> statusHistory,
      Instant createdAt,
      Instant updatedAt) {}

  public record PlaceOrderResult(
      String orderId,
      String orderNumber,
      String paymentId,
      String paymentStatus,
      String paymentMethod,
      BigDecimal totalAmount,
      int itemCount) {}
}
