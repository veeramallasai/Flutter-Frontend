package com.farmtohome.api.coupon;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;

@Entity
@Table(name = "coupons")
public class CouponEntity {
  @Id
  private String id;
  @Column(nullable = false, unique = true)
  private String code;
  @Column(nullable = false)
  private String title;
  @Column(nullable = false)
  private String discountType;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal discountValue;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal minimumOrder;
  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal maximumDiscount;
  @Column(nullable = false)
  private boolean active;

  public String getId() { return id; }
  public String getCode() { return code; }
  public String getTitle() { return title; }
  public String getDiscountType() { return discountType; }
  public BigDecimal getDiscountValue() { return discountValue; }
  public BigDecimal getMinimumOrder() { return minimumOrder; }
  public BigDecimal getMaximumDiscount() { return maximumDiscount; }
  public boolean isActive() { return active; }
}
