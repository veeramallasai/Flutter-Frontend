package com.farmtohome.api.cart;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.Instant;

@Entity
@Table(name = "cart_items", uniqueConstraints =
    @UniqueConstraint(name = "uk_cart_item_owner_key", columnNames = {"owner_uid", "item_key"}))
public class CartItemEntity {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;
  @Column(name = "owner_uid", nullable = false)
  private String ownerUid;
  @Column(name = "item_key", nullable = false)
  private String itemKey;
  @Column(nullable = false)
  private String productId;
  @Column(nullable = false)
  private String shoppingMode;
  @Column(nullable = false)
  private String unit;
  @Column(nullable = false)
  private int quantity;
  @Column(nullable = false)
  private Instant updatedAt;

  protected CartItemEntity() {}

  public CartItemEntity(
      String ownerUid,
      String itemKey,
      String productId,
      String shoppingMode,
      String unit,
      int quantity) {
    this.ownerUid = ownerUid;
    this.itemKey = itemKey;
    this.productId = productId;
    this.shoppingMode = shoppingMode;
    this.unit = unit;
    this.quantity = quantity;
    this.updatedAt = Instant.now();
  }

  public Long getId() { return id; }
  public String getOwnerUid() { return ownerUid; }
  public String getItemKey() { return itemKey; }
  public String getProductId() { return productId; }
  public String getShoppingMode() { return shoppingMode; }
  public String getUnit() { return unit; }
  public int getQuantity() { return quantity; }
  public void setQuantity(int quantity) { this.quantity = quantity; this.updatedAt = Instant.now(); }
}
