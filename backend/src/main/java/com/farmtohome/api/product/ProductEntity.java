package com.farmtohome.api.product;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "products")
public class ProductEntity {
  @Id
  private String id;
  @Column(nullable = false)
  private String name;
  @Column(nullable = false)
  private String englishName;
  @Column(nullable = false)
  private String teluguName;
  @Column(nullable = false, length = 800)
  private String description;
  @Column(nullable = false)
  private String category;
  @Column(nullable = false, length = 500)
  private String imageUrl;
  @Column(nullable = false)
  private String unit;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal price;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal mrp;
  @Column(nullable = false)
  private String shopUnit;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal shopPrice;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal shopMrp;
  @Column(nullable = false)
  private int stockQuantity;
  @Column(nullable = false)
  private boolean active;
  @Column(nullable = false)
  private boolean fresh;
  @Column(nullable = false, precision = 3, scale = 2)
  private BigDecimal rating;
  @Column(nullable = false)
  private int reviewCount;
  @Column(nullable = false)
  private Instant createdAt;
  @Column(nullable = false)
  private Instant updatedAt;

  public String getId() { return id; }
  public String getName() { return name; }
  public String getEnglishName() { return englishName; }
  public String getTeluguName() { return teluguName; }
  public String getDescription() { return description; }
  public String getCategory() { return category; }
  public String getImageUrl() { return imageUrl; }
  public String getUnit() { return unit; }
  public BigDecimal getPrice() { return price; }
  public BigDecimal getMrp() { return mrp; }
  public String getShopUnit() { return shopUnit; }
  public BigDecimal getShopPrice() { return shopPrice; }
  public BigDecimal getShopMrp() { return shopMrp; }
  public int getStockQuantity() { return stockQuantity; }
  public boolean isActive() { return active; }
  public boolean isFresh() { return fresh; }
  public BigDecimal getRating() { return rating; }
  public int getReviewCount() { return reviewCount; }
  public Instant getCreatedAt() { return createdAt; }
  public Instant getUpdatedAt() { return updatedAt; }
  public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }
  public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
