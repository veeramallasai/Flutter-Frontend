package com.farmtohome.api.order;

import com.farmtohome.api.common.ApiResponse;
import jakarta.validation.Valid;
import java.security.Principal;
import java.util.List;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {
  private final OrderService orders;

  public OrderController(OrderService orders) {
    this.orders = orders;
  }

  @PostMapping
  ApiResponse<OrderDtos.PlaceOrderResult> place(
      Principal principal,
      @Valid @RequestBody OrderDtos.PlaceOrderRequest request) {
    return ApiResponse.ok(orders.place(principal.getName(), request), "Order placed.");
  }

  @GetMapping
  ApiResponse<List<OrderDtos.Order>> list(Principal principal) {
    return ApiResponse.ok(orders.list(principal.getName()));
  }

  @GetMapping("/{id}")
  ApiResponse<OrderDtos.Order> one(Principal principal, @PathVariable UUID id) {
    return ApiResponse.ok(orders.get(principal.getName(), id));
  }

  @PostMapping("/{id}/cancel")
  ApiResponse<OrderDtos.Order> cancel(
      Principal principal,
      @PathVariable UUID id,
      @RequestBody(required = false) OrderDtos.CancelRequest request) {
    String reason = request == null ? "" : request.reason();
    return ApiResponse.ok(orders.cancel(principal.getName(), id, reason), "Order cancelled.");
  }

  @PostMapping("/{id}/reorder")
  ApiResponse<Integer> reorder(Principal principal, @PathVariable UUID id) {
    return ApiResponse.ok(orders.reorder(principal.getName(), id), "Items added to cart.");
  }
}
