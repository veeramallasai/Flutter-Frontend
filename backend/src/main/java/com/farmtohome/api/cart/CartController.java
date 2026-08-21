package com.farmtohome.api.cart;

import com.farmtohome.api.common.ApiResponse;
import jakarta.validation.Valid;
import java.security.Principal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/cart")
public class CartController {
  private final CartService cart;

  public CartController(CartService cart) {
    this.cart = cart;
  }

  @GetMapping
  ApiResponse<CartDtos.Cart> get(Principal principal) {
    return ApiResponse.ok(cart.view(principal.getName()));
  }

  @PostMapping("/items")
  ApiResponse<CartDtos.Cart> add(
      Principal principal,
      @Valid @RequestBody CartDtos.AddItemRequest request) {
    return ApiResponse.ok(cart.add(principal.getName(), request), "Added to cart.");
  }

  @PatchMapping("/items/{itemKey}")
  ApiResponse<CartDtos.Cart> quantity(
      Principal principal,
      @PathVariable String itemKey,
      @Valid @RequestBody CartDtos.QuantityRequest request) {
    return ApiResponse.ok(cart.quantity(principal.getName(), itemKey, request.quantity()));
  }

  @DeleteMapping("/items/{itemKey}")
  ApiResponse<CartDtos.Cart> remove(Principal principal, @PathVariable String itemKey) {
    return ApiResponse.ok(cart.remove(principal.getName(), itemKey));
  }

  @PostMapping("/coupon")
  ApiResponse<CartDtos.Cart> coupon(
      Principal principal,
      @Valid @RequestBody CartDtos.CouponRequest request) {
    return ApiResponse.ok(cart.applyCoupon(principal.getName(), request.couponCode()));
  }

  @DeleteMapping("/coupon")
  ApiResponse<CartDtos.Cart> removeCoupon(Principal principal) {
    return ApiResponse.ok(cart.removeCoupon(principal.getName()), "Coupon removed.");
  }

  @DeleteMapping
  ApiResponse<CartDtos.Cart> clear(Principal principal) {
    return ApiResponse.ok(cart.clear(principal.getName()));
  }
}
