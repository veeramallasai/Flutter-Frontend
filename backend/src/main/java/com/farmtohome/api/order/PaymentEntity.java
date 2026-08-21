package com.farmtohome.api.order;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "payments")
public class PaymentEntity {
  @Id
  private UUID id;
  @Column(nullable = false)
  private UUID orderId;
  @Column(nullable = false)
  private String ownerUid;
  @Column(nullable = false)
  private String method;
  @Column(nullable = false)
  private String status;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal totalAmount;
  @Column(nullable = false)
  private String transactionId;
  @Column(nullable = false)
  private String gateway;
  @Column(nullable = false)
  private Instant createdAt;
  @Column(nullable = false)
  private Instant updatedAt;

  protected PaymentEntity() {}

  public PaymentEntity(UUID id, UUID orderId, String ownerUid, BigDecimal totalAmount) {
    this.id = id;
    this.orderId = orderId;
    this.ownerUid = ownerUid;
    this.method = "cash_on_delivery";
    this.status = "pending";
    this.totalAmount = totalAmount;
    this.transactionId = "";
    this.gateway = "cash_on_delivery";
    this.createdAt = Instant.now();
    this.updatedAt = this.createdAt;
  }

  public UUID getId() { return id; }
  public void cancel() { this.status = "cancelled"; this.updatedAt = Instant.now(); }
}
