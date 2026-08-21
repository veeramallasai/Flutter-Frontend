package com.farmtohome.api.order;

import com.farmtohome.api.address.AddressService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.farmtohome.api.cart.CartEntity;
import com.farmtohome.api.cart.CartItemEntity;
import com.farmtohome.api.cart.CartItemRepository;
import com.farmtohome.api.cart.CartRepository;
import com.farmtohome.api.cart.CartService;
import com.farmtohome.api.common.ApiException;
import com.farmtohome.api.product.ProductEntity;
import com.farmtohome.api.product.ProductRepository;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderService {
  private final OrderRepository orders;
  private final OrderItemRepository orderItems;
  private final PaymentRepository payments;
  private final CartRepository carts;
  private final CartItemRepository cartItems;
  private final ProductRepository products;
  private final CartService cartService;
  private final AddressService addressService;
  private final ObjectMapper objectMapper;
  private final JdbcTemplate jdbc;

  public OrderService(
      OrderRepository orders,
      OrderItemRepository orderItems,
      PaymentRepository payments,
      CartRepository carts,
      CartItemRepository cartItems,
      ProductRepository products,
      CartService cartService,
      AddressService addressService,
      ObjectMapper objectMapper,
      JdbcTemplate jdbc) {
    this.orders = orders;
    this.orderItems = orderItems;
    this.payments = payments;
    this.carts = carts;
    this.cartItems = cartItems;
    this.products = products;
    this.cartService = cartService;
    this.addressService = addressService;
    this.objectMapper = objectMapper;
    this.jdbc = jdbc;
  }

  @Transactional
  public OrderDtos.PlaceOrderResult place(String uid, OrderDtos.PlaceOrderRequest request) {
    String paymentMethod = safe(request.paymentMethod(), "cash_on_delivery");
    if (!"cash_on_delivery".equals(paymentMethod)) {
      throw new ApiException(HttpStatus.CONFLICT,
          "Online payment requires Razorpay production credentials.");
    }
    String mode = "shop".equalsIgnoreCase(request.shoppingMode()) ? "shop" : "home";
    CartEntity cart = carts.findById(uid)
        .orElseThrow(() -> new ApiException(HttpStatus.CONFLICT, "Your cart is empty."));
    List<CartItemEntity> currentItems = cartItems.findByOwnerUidOrderByUpdatedAtDesc(uid);
    if (currentItems.isEmpty()) {
      throw new ApiException(HttpStatus.CONFLICT, "Your cart is empty.");
    }
    if (!mode.equals(cart.getShoppingMode())) {
      throw new ApiException(HttpStatus.CONFLICT, "Cart shopping mode changed. Please refresh.");
    }

    UUID orderId = UUID.randomUUID();
    UUID paymentId = UUID.randomUUID();
    List<OrderItemEntity> savedItems = new ArrayList<>();
    BigDecimal subtotal = BigDecimal.ZERO;
    BigDecimal mrpTotal = BigDecimal.ZERO;
    int itemCount = 0;

    for (CartItemEntity item : currentItems) {
      ProductEntity product = products.findForUpdate(item.getProductId());
      if (product == null || !product.isActive()) {
        throw new ApiException(HttpStatus.CONFLICT, "A product in your cart is unavailable.");
      }
      if (product.getStockQuantity() < item.getQuantity()) {
        throw new ApiException(HttpStatus.CONFLICT,
            "Only " + product.getStockQuantity() + " unit(s) of " + product.getName() + " available.");
      }
      BigDecimal price = mode.equals("shop") ? product.getShopPrice() : product.getPrice();
      BigDecimal mrp = mode.equals("shop") ? product.getShopMrp() : product.getMrp();
      subtotal = subtotal.add(price.multiply(BigDecimal.valueOf(item.getQuantity())));
      mrpTotal = mrpTotal.add(mrp.multiply(BigDecimal.valueOf(item.getQuantity())));
      itemCount += item.getQuantity();
      product.setStockQuantity(product.getStockQuantity() - item.getQuantity());
      product.setUpdatedAt(Instant.now());
      products.save(product);
      savedItems.add(new OrderItemEntity(
          orderId, item.getItemKey(), product.getId(), product.getName(),
          product.getImageUrl(), product.getCategory(), item.getUnit(), mode,
          price, mrp, item.getQuantity()));
    }

    String couponCode = safe(request.couponCode(), cart.getCouponCode()).toUpperCase();
    BigDecimal couponDiscount = cartService.calculateDiscount(couponCode, subtotal);
    String deliveryMethod = safe(request.deliveryMethod(), "quick").toLowerCase();
    if (!List.of("quick", "scheduled", "preorder", "pre_order").contains(deliveryMethod)) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Invalid delivery method.");
    }
    BigDecimal deliveryFee = subtotal.compareTo(BigDecimal.valueOf(499)) >= 0
        ? BigDecimal.ZERO
        : deliveryMethod.equals("scheduled") ? BigDecimal.valueOf(20)
        : deliveryMethod.startsWith("pre") ? BigDecimal.ZERO : BigDecimal.valueOf(35);
    BigDecimal total = CartService.money(subtotal.subtract(couponDiscount).add(deliveryFee));
    String orderNumber = "FTH" + System.currentTimeMillis() % 10_000_000L
        + ThreadLocalRandom.current().nextInt(10, 99);
    Map<String, Object> deliveryAddress = addressService.snapshot(uid, request.addressId());
    String addressJson;
    try {
      addressJson = objectMapper.writeValueAsString(deliveryAddress);
    } catch (JsonProcessingException error) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Invalid delivery address.");
    }

    OrderEntity order = new OrderEntity(
        orderId, orderNumber, uid, mode, paymentId,
        CartService.money(subtotal), CartService.money(mrpTotal), couponDiscount,
        CartService.money(deliveryFee), total, itemCount, couponCode,
        request.addressId().trim(), addressJson, deliveryMethod, request.deliveryDate(),
        safe(request.deliverySlot(), "Earliest available"));
    orders.save(order);
    orderItems.saveAll(savedItems);
    payments.save(new PaymentEntity(paymentId, orderId, uid, total));
    cartItems.deleteByOwnerUid(uid);
    cart.setCouponCode("");
    cart.touch();
    carts.save(cart);

    createNotification(
        uid,
        "Order placed successfully",
        "Your order " + orderNumber + " is confirmed for cash on delivery.",
        "order",
        "/order-details?id=" + orderId,
        Map.of("orderId", orderId.toString(), "orderNumber", orderNumber));

    return new OrderDtos.PlaceOrderResult(
        orderId.toString(), orderNumber, paymentId.toString(), "pending",
        "cash_on_delivery", total, itemCount);
  }

  @Transactional(readOnly = true)
  public List<OrderDtos.Order> list(String uid) {
    return orders.findByOwnerUidOrderByCreatedAtDesc(uid).stream()
        .map(this::view)
        .toList();
  }

  @Transactional(readOnly = true)
  public OrderDtos.Order get(String uid, UUID id) {
    return view(orders.findByIdAndOwnerUid(id, uid)
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Order not found.")));
  }

  @Transactional
  public OrderDtos.Order cancel(String uid, UUID id, String reason) {
    OrderEntity order = orders.findOwnedForUpdate(id, uid)
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Order not found."));
    if (!List.of("placed", "confirmed", "processing").contains(order.getStatus())) {
      throw new ApiException(HttpStatus.CONFLICT, "This order cannot be cancelled now.");
    }
    List<OrderItemEntity> values = orderItems.findByOrderIdOrderById(id);
    for (OrderItemEntity item : values) {
      ProductEntity product = products.findForUpdate(item.getProductId());
      if (product != null) {
        product.setStockQuantity(product.getStockQuantity() + item.getQuantity());
        product.setUpdatedAt(Instant.now());
        products.save(product);
      }
    }
    order.cancel(safe(reason, "Cancelled by customer"));
    orders.save(order);
    payments.findById(order.getPaymentId()).ifPresent(payment -> {
      payment.cancel();
      payments.save(payment);
    });
    createNotification(
        uid,
        "Order cancelled",
        "Order " + order.getOrderNumber() + " was cancelled and stock was restored.",
        "order",
        "/order-details?id=" + order.getId(),
        Map.of("orderId", order.getId().toString(), "status", "cancelled"));
    return view(order);
  }

  @Transactional
  public int reorder(String uid, UUID id) {
    OrderEntity order = orders.findByIdAndOwnerUid(id, uid)
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Order not found."));
    List<OrderItemEntity> previousItems = orderItems.findByOrderIdOrderById(id);
    if (previousItems.isEmpty()) {
      throw new ApiException(HttpStatus.CONFLICT, "No items are available to reorder.");
    }
    CartEntity cart = carts.findById(uid)
        .orElseGet(() -> new CartEntity(uid, order.getShoppingMode()));
    List<CartItemEntity> existing = cartItems.findByOwnerUidOrderByUpdatedAtDesc(uid);
    if (!existing.isEmpty() && !cart.getShoppingMode().equals(order.getShoppingMode())) {
      throw new ApiException(HttpStatus.CONFLICT, "Clear the current cart before reordering.");
    }
    cart.setShoppingMode(order.getShoppingMode());
    cart.touch();
    carts.save(cart);
    int added = 0;
    for (OrderItemEntity previous : previousItems) {
      ProductEntity product = products.findById(previous.getProductId()).orElse(null);
      if (product == null || !product.isActive() || product.getStockQuantity() <= 0) continue;
      CartItemEntity item = cartItems
          .findByOwnerUidAndItemKey(uid, previous.getCartItemId())
          .orElseGet(() -> new CartItemEntity(
              uid, previous.getCartItemId(), previous.getProductId(),
              order.getShoppingMode(), previous.getUnit(), 0));
      int quantity = Math.min(
          Math.min(99, product.getStockQuantity()),
          item.getQuantity() + previous.getQuantity());
      item.setQuantity(quantity);
      cartItems.save(item);
      added += 1;
    }
    if (added == 0) {
      throw new ApiException(HttpStatus.CONFLICT, "These products are currently unavailable.");
    }
    return added;
  }

  private OrderDtos.Order view(OrderEntity order) {
    List<OrderDtos.Item> items = orderItems.findByOrderIdOrderById(order.getId()).stream()
        .map(item -> new OrderDtos.Item(
            item.getCartItemId(), item.getCartItemId(), item.getProductId(),
            item.getName(), item.getImageUrl(), item.getCategory(), item.getUnit(),
            item.getShoppingMode(), item.getUnitPrice(), item.getMrp(),
            item.getQuantity(), item.getLineTotal(), true))
        .toList();
    Map<String, Object> address;
    try {
      address = objectMapper.readValue(order.getAddressJson(), new TypeReference<>() {});
    } catch (JsonProcessingException error) {
      address = Map.of();
    }
    List<Map<String, Object>> history = new ArrayList<>();
    history.add(Map.of("status", "placed", "time", order.getCreatedAt(), "note", "Order placed"));
    if ("cancelled".equals(order.getStatus())) {
      history.add(Map.of("status", "cancelled", "time", order.getUpdatedAt(),
          "note", order.getCancellationReason()));
    }
    return new OrderDtos.Order(
        order.getId().toString(), order.getId().toString(), order.getOrderNumber(),
        order.getOwnerUid(), order.getShoppingMode(), order.getStatus(),
        order.getPaymentStatus(), order.getPaymentMethod(), order.getPaymentId().toString(),
        "", items, order.getItemCount(), order.getSubtotal(), order.getMrpTotal(),
        order.getProductSavings(), order.getCouponCode(), order.getCouponDiscount(),
        order.getDeliveryFee(), order.getTotalAmount(), order.getAddressId(), address,
        order.getDeliveryMethod(), order.getDeliveryDate(), order.getDeliverySlot(),
        order.getCancellationReason(), history, order.getCreatedAt(), order.getUpdatedAt());
  }

  private static String safe(String value, String fallback) {
    return value == null || value.isBlank() ? fallback : value.trim();
  }

  private void createNotification(
      String uid,
      String title,
      String body,
      String type,
      String route,
      Map<String, Object> data) {
    String encodedData;
    try {
      encodedData = objectMapper.writeValueAsString(data);
    } catch (JsonProcessingException error) {
      encodedData = "{}";
    }
    jdbc.update("""
        INSERT INTO notifications(
          id, owner_uid, title, body, notification_type, route, data_json)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """, UUID.randomUUID(), uid, title, body, type, route, encodedData);
  }
}
