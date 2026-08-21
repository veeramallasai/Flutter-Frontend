package com.farmtohome.api.product;

import com.farmtohome.api.common.ApiException;
import com.farmtohome.api.common.ApiResponse;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/products")
public class ProductController {
  private final ProductRepository products;

  public ProductController(ProductRepository products) {
    this.products = products;
  }

  @GetMapping
  ApiResponse<List<ProductView>> list(
      @RequestParam(defaultValue = "") String category,
      @RequestParam(defaultValue = "home") String shoppingMode,
      @RequestParam(defaultValue = "200") int limit) {
    List<ProductEntity> values = category.isBlank()
        ? products.findByActiveTrueOrderByCreatedAtDesc()
        : products.findByActiveTrueAndCategoryIgnoreCaseOrderByCreatedAtDesc(category.trim());
    int safeLimit = Math.max(1, Math.min(limit, 250));
    List<ProductView> data = values.stream()
        .limit(safeLimit)
        .map(value -> ProductView.from(value, shoppingMode))
        .toList();
    return ApiResponse.ok(data);
  }

  @GetMapping("/{id}")
  ApiResponse<ProductView> one(
      @PathVariable String id,
      @RequestParam(defaultValue = "home") String shoppingMode) {
    ProductEntity product = products.findById(id)
        .filter(ProductEntity::isActive)
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Product not found."));
    return ApiResponse.ok(ProductView.from(product, shoppingMode));
  }
}
