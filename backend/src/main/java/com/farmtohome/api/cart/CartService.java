package com.farmtohome.api.cart;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.farmtohome.api.common.ApiException;
import com.farmtohome.api.coupon.CouponEntity;
import com.farmtohome.api.coupon.CouponRepository;
import com.farmtohome.api.product.ProductEntity;
import com.farmtohome.api.product.ProductRepository;

@Service
public class CartService {
  private static final BigDecimal ZERO = BigDecimal.ZERO.setScale(2);
  private final CartRepository carts;
  private final CartItemRepository items;
  private final ProductRepository products;
  private final CouponRepository coupons;

  public CartService(
      CartRepository carts,
      CartItemRepository items,
      ProductRepository products,
      CouponRepository coupons) {
    this.carts = carts;
    this.items = items;
    this.products = products;
    this.coupons = coupons;
  }

  @Transactional(readOnly = true)
  public CartDtos.Cart view(String uid) {
    CartEntity cart = carts.findById(uid).orElse(new CartEntity(uid, "home"));
    return build(uid, cart, items.findByOwnerUidOrderByUpdatedAtDesc(uid));
  }

  @Transactional
  public CartDtos.Cart add(String uid, CartDtos.AddItemRequest request) {
    String mode = "shop".equalsIgnoreCase(request.shoppingMode()) ? "shop" : "home";
    ProductEntity product = products.findById(request.productId().trim())
        .filter(ProductEntity::isActive)
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Product is unavailable."));
    if (product.getStockQuantity() < request.quantity()) {
      throw new ApiException(HttpStatus.CONFLICT, "Requested quantity is not in stock.");
    }
    CartEntity cart = carts.findById(uid).orElseGet(() -> new CartEntity(uid, mode));
    List<CartItemEntity> currentItems = items.findByOwnerUidOrderByUpdatedAtDesc(uid);
    if (!currentItems.isEmpty() && !cart.getShoppingMode().equals(mode)) {
      throw new ApiException(HttpStatus.CONFLICT, "Clear the current cart before changing shopping mode.");
    }
    cart.setShoppingMode(mode);
    cart.touch();
    carts.save(cart);

    String defaultUnit = mode.equals("shop") ? product.getShopUnit() : product.getUnit();
    String unit = request.unit() == null || request.unit().isBlank()
        ? defaultUnit : request.unit().trim();
    String itemKey = request.itemId() == null || request.itemId().isBlank()
        ? product.getId() + "_" + mode
        : request.itemId().trim();
    if (itemKey.length() > 180) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Invalid cart item.");
    }
    CartItemEntity item = items.findByOwnerUidAndItemKey(uid, itemKey)
        .orElseGet(() -> new CartItemEntity(uid, itemKey, product.getId(), mode, unit, 0));
    int quantity = Math.min(99, item.getQuantity() + request.quantity());
    if (quantity > product.getStockQuantity()) {
      throw new ApiException(HttpStatus.CONFLICT, "Requested quantity is not in stock.");
    }
    item.setQuantity(quantity);
    items.save(item);
    return view(uid);
  }

  @Transactional
  public CartDtos.Cart quantity(String uid, String itemKey, int quantity) {
    CartItemEntity item = items.findByOwnerUidAndItemKey(uid, itemKey)
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Cart item not found."));
    if (quantity <= 0) {
      items.delete(item);
    } else {
      ProductEntity product = products.findById(item.getProductId())
          .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Product is unavailable."));
      if (quantity > product.getStockQuantity()) {
        throw new ApiException(HttpStatus.CONFLICT, "Only " + product.getStockQuantity() + " available.");
      }
      item.setQuantity(Math.min(quantity, 99));
      items.save(item);
    }
    carts.findById(uid).ifPresent(value -> { value.touch(); carts.save(value); });
    return view(uid);
  }

  @Transactional
  public CartDtos.Cart remove(String uid, String itemKey) {
    items.deleteByOwnerUidAndItemKey(uid, itemKey);
    carts.findById(uid).ifPresent(value -> { value.touch(); carts.save(value); });
    return view(uid);
  }

  @Transactional
  public CartDtos.Cart applyCoupon(String uid, String couponCode) {
    CouponEntity coupon = coupons.findByCodeIgnoreCaseAndActiveTrue(couponCode.trim())
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Coupon code is not valid."));
    CartEntity cart = carts.findById(uid).orElseGet(() -> new CartEntity(uid, "home"));
    CartDtos.Cart current = build(uid, cart, items.findByOwnerUidOrderByUpdatedAtDesc(uid));
    if (current.subtotal().compareTo(coupon.getMinimumOrder()) < 0) {
      throw new ApiException(HttpStatus.CONFLICT,
          "Minimum order for this coupon is ₹" + coupon.getMinimumOrder().setScale(0));
    }
    cart.setCouponCode(coupon.getCode());
    cart.touch();
    carts.save(cart);
    return view(uid);
  }

  @Transactional
  public CartDtos.Cart removeCoupon(String uid) {
    CartEntity cart = carts.findById(uid).orElseGet(() -> new CartEntity(uid, "home"));
    cart.setCouponCode("");
    cart.touch();
    carts.save(cart);
    return view(uid);
  }

  @Transactional
  public CartDtos.Cart clear(String uid) {
    items.deleteByOwnerUid(uid);
    CartEntity cart = carts.findById(uid).orElseGet(() -> new CartEntity(uid, "home"));
    cart.setCouponCode("");
    cart.touch();
    carts.save(cart);
    return view(uid);
  }

  private CartDtos.Cart build(String uid, CartEntity cart, List<CartItemEntity> cartItems) {
    Map<String, ProductEntity> productMap = products.findAllById(
            cartItems.stream().map(CartItemEntity::getProductId).toList()).stream()
        .collect(Collectors.toMap(ProductEntity::getId, Function.identity()));
    List<CartDtos.Item> result = new ArrayList<>();
    BigDecimal subtotal = ZERO;
    BigDecimal mrpTotal = ZERO;
    int itemCount = 0;
    for (CartItemEntity item : cartItems) {
      ProductEntity product = productMap.get(item.getProductId());
      if (product == null || !product.isActive()) continue;
      boolean shop = "shop".equals(item.getShoppingMode());
      BigDecimal price = priceFor(product, shop);
      BigDecimal mrp = mrpFor(product, shop, price);
      subtotal = subtotal.add(price.multiply(BigDecimal.valueOf(item.getQuantity())));
      mrpTotal = mrpTotal.add(mrp.multiply(BigDecimal.valueOf(item.getQuantity())));
      itemCount += item.getQuantity();
      result.add(new CartDtos.Item(
          item.getItemKey(), product.getId(), product.getName(), product.getImageUrl(),
          product.getCategory(), item.getUnit(), item.getShoppingMode(), price, mrp,
          item.getQuantity(), ""));
    }
    BigDecimal discount = calculateDiscount(cart.getCouponCode(), subtotal);
    BigDecimal total = subtotal.subtract(discount).max(ZERO);
    return new CartDtos.Cart(
        uid, cart.getShoppingMode(), result, cart.getCouponCode(), money(discount),
        money(subtotal), money(mrpTotal.subtract(subtotal).max(ZERO)), money(total),
        itemCount, cart.getUpdatedAt() == null ? Instant.now() : cart.getUpdatedAt());
  }

  private BigDecimal priceFor(ProductEntity product, boolean shop) {
    BigDecimal price = shop ? product.getShopPrice() : product.getPrice();
    if (price == null && shop) price = product.getPrice();
    if (price == null || price.signum() <= 0) {
      throw new ApiException(HttpStatus.CONFLICT, "Product price is unavailable. Please try another product.");
    }
    return price;
  }

  private BigDecimal mrpFor(ProductEntity product, boolean shop, BigDecimal price) {
    BigDecimal mrp = shop ? product.getShopMrp() : product.getMrp();
    if (mrp == null && shop) mrp = product.getMrp();
    return mrp == null || mrp.compareTo(price) < 0 ? price : mrp;
  }

  public BigDecimal calculateDiscount(String code, BigDecimal subtotal) {
    if (code == null || code.isBlank()) return ZERO;
    return coupons.findByCodeIgnoreCaseAndActiveTrue(code).map(coupon -> {
      if (subtotal.compareTo(coupon.getMinimumOrder()) < 0) return ZERO;
      BigDecimal discount = "fixed".equalsIgnoreCase(coupon.getDiscountType())
          ? coupon.getDiscountValue()
          : subtotal.multiply(coupon.getDiscountValue())
              .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
      if (coupon.getMaximumDiscount().signum() > 0) {
        discount = discount.min(coupon.getMaximumDiscount());
      }
      return money(discount.min(subtotal));
    }).orElse(ZERO);
  }

  public static BigDecimal money(BigDecimal value) {
    return value.setScale(2, RoundingMode.HALF_UP);
  }
}
