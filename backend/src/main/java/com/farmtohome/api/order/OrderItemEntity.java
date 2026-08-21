package com.farmtohome.api.order;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "order_items")
public class OrderItemEntity {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;
  @Column(nullable = false)
  private UUID orderId;
  @Column(nullable = false)
  private String cartItemId;
  @Column(nullable = false)
  private String productId;
  @Column(nullable = false)
  private String name;
  @Column(nullable = false)
  private String imageUrl;
  @Column(nullable = false)
  private String category;
  @Column(nullable = false)
  private String unit;
  @Column(nullable = false)
  private String shoppingMode;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal unitPrice;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal mrp;
  @Column(nullable = false)
  private int quantity;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal lineTotal;

  protected OrderItemEntity() {}

  public OrderItemEntity(
      UUID orderId, String cartItemId, String productId, String name,
      String imageUrl, String category, String unit, String shoppingMode,
      BigDecimal unitPrice, BigDecimal mrp, int quantity) {
    this.orderId = orderId;
    this.cartItemId = cartItemId;
    this.productId = productId;
    this.name = name;
    this.imageUrl = imageUrl;
    this.category = category;
    this.unit = unit;
    this.shoppingMode = shoppingMode;
    this.unitPrice = unitPrice;
    this.mrp = mrp;
    this.quantity = quantity;
    this.lineTotal = unitPrice.multiply(BigDecimal.valueOf(quantity));
  }

  public Long getId() { return id; }
  public UUID getOrderId() { return orderId; }
  public String getCartItemId() { return cartItemId; }
  public String getProductId() { return productId; }
  public String getName() { return name; }
  public String getImageUrl() { return imageUrl; }
  public String getCategory() { return category; }
  public String getUnit() { return unit; }
  public String getShoppingMode() { return shoppingMode; }
  public BigDecimal getUnitPrice() { return unitPrice; }
  public BigDecimal getMrp() { return mrp; }
  public int getQuantity() { return quantity; }
  public BigDecimal getLineTotal() { return lineTotal; }
}
