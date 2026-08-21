package com.farmtohome.api.order;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "orders")
public class OrderEntity {
  @Id
  private UUID id;
  @Column(nullable = false, unique = true)
  private String orderNumber;
  @Column(nullable = false)
  private String ownerUid;
  @Column(nullable = false)
  private String shoppingMode;
  @Column(nullable = false)
  private String status;
  @Column(nullable = false)
  private String paymentStatus;
  @Column(nullable = false)
  private String paymentMethod;
  @Column(nullable = false)
  private UUID paymentId;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal subtotal;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal mrpTotal;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal productSavings;
  @Column(nullable = false)
  private String couponCode;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal couponDiscount;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal deliveryFee;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal totalAmount;
  @Column(nullable = false)
  private int itemCount;
  @Column(nullable = false)
  private String addressId;
  @Column(nullable = false, columnDefinition = "text")
  private String addressJson;
  @Column(nullable = false)
  private String deliveryMethod;
  private LocalDate deliveryDate;
  @Column(nullable = false)
  private String deliverySlot;
  @Column(nullable = false)
  private String cancellationReason;
  @Column(nullable = false)
  private Instant createdAt;
  @Column(nullable = false)
  private Instant updatedAt;

  protected OrderEntity() {}

  public OrderEntity(
      UUID id, String orderNumber, String ownerUid, String shoppingMode,
      UUID paymentId, BigDecimal subtotal, BigDecimal mrpTotal,
      BigDecimal couponDiscount, BigDecimal deliveryFee, BigDecimal totalAmount,
      int itemCount, String couponCode, String addressId, String addressJson,
      String deliveryMethod, LocalDate deliveryDate, String deliverySlot) {
    this.id = id;
    this.orderNumber = orderNumber;
    this.ownerUid = ownerUid;
    this.shoppingMode = shoppingMode;
    this.status = "placed";
    this.paymentStatus = "pending";
    this.paymentMethod = "cash_on_delivery";
    this.paymentId = paymentId;
    this.subtotal = subtotal;
    this.mrpTotal = mrpTotal;
    this.productSavings = mrpTotal.subtract(subtotal).max(BigDecimal.ZERO);
    this.couponCode = couponCode;
    this.couponDiscount = couponDiscount;
    this.deliveryFee = deliveryFee;
    this.totalAmount = totalAmount;
    this.itemCount = itemCount;
    this.addressId = addressId;
    this.addressJson = addressJson;
    this.deliveryMethod = deliveryMethod;
    this.deliveryDate = deliveryDate;
    this.deliverySlot = deliverySlot;
    this.cancellationReason = "";
    this.createdAt = Instant.now();
    this.updatedAt = this.createdAt;
  }

  public UUID getId() { return id; }
  public String getOrderNumber() { return orderNumber; }
  public String getOwnerUid() { return ownerUid; }
  public String getShoppingMode() { return shoppingMode; }
  public String getStatus() { return status; }
  public String getPaymentStatus() { return paymentStatus; }
  public String getPaymentMethod() { return paymentMethod; }
  public UUID getPaymentId() { return paymentId; }
  public BigDecimal getSubtotal() { return subtotal; }
  public BigDecimal getMrpTotal() { return mrpTotal; }
  public BigDecimal getProductSavings() { return productSavings; }
  public String getCouponCode() { return couponCode; }
  public BigDecimal getCouponDiscount() { return couponDiscount; }
  public BigDecimal getDeliveryFee() { return deliveryFee; }
  public BigDecimal getTotalAmount() { return totalAmount; }
  public int getItemCount() { return itemCount; }
  public String getAddressId() { return addressId; }
  public String getAddressJson() { return addressJson; }
  public String getDeliveryMethod() { return deliveryMethod; }
  public LocalDate getDeliveryDate() { return deliveryDate; }
  public String getDeliverySlot() { return deliverySlot; }
  public String getCancellationReason() { return cancellationReason; }
  public Instant getCreatedAt() { return createdAt; }
  public Instant getUpdatedAt() { return updatedAt; }
  public void cancel(String reason) {
    this.status = "cancelled";
    this.cancellationReason = reason;
    this.updatedAt = Instant.now();
  }
}
