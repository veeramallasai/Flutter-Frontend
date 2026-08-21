package com.farmtohome.api.product;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;

public record ProductView(
    String id,
    String name,
    String englishName,
    String teluguName,
    String description,
    String category,
    String imageUrl,
    List<String> images,
    String shoppingMode,
    String unit,
    BigDecimal price,
    BigDecimal mrp,
    int stockQuantity,
    boolean inStock,
    boolean isFresh,
    BigDecimal rating,
    int reviewCount,
    String farmerId,
    Map<String, String> nutritionInfo,
    List<String> benefits,
    Instant createdAt,
    Instant updatedAt) {

  public static ProductView from(ProductEntity product, String requestedMode) {
    boolean shop = "shop".equalsIgnoreCase(requestedMode);
    return new ProductView(
        product.getId(),
        product.getName(),
        product.getEnglishName(),
        product.getTeluguName(),
        product.getDescription(),
        product.getCategory(),
        product.getImageUrl(),
        List.of(product.getImageUrl()),
        shop ? "shop" : "home",
        shop ? product.getShopUnit() : product.getUnit(),
        shop ? product.getShopPrice() : product.getPrice(),
        shop ? product.getShopMrp() : product.getMrp(),
        product.getStockQuantity(),
        product.getStockQuantity() > 0,
        product.isFresh(),
        product.getRating(),
        product.getReviewCount(),
        "",
        Map.of("Quality", "Farm-fresh and quality checked"),
        List.of("Quality checked", "Hygienically packed", "Fresh delivery"),
        product.getCreatedAt(),
        product.getUpdatedAt());
  }
}
