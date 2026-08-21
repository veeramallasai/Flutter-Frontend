package com.farmtohome.api.address;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "addresses")
public class AddressEntity {
  @Id
  private UUID id;

  @Column(name = "owner_uid", nullable = false, length = 160)
  private String ownerUid;

  @Column(name = "full_name", nullable = false, length = 160)
  private String fullName;

  @Column(nullable = false, length = 32)
  private String phone;

  @Column(name = "address_line1", nullable = false, length = 300)
  private String addressLine1;

  @Column(name = "address_line2", nullable = false, length = 300)
  private String addressLine2;

  @Column(nullable = false, length = 120)
  private String city;

  @Column(nullable = false, length = 120)
  private String state;

  @Column(name = "postal_code", nullable = false, length = 12)
  private String postalCode;

  @Column(nullable = false, length = 200)
  private String landmark;

  @Column(name = "address_type", nullable = false, length = 20)
  private String addressType;

  @Column(name = "is_default", nullable = false)
  private boolean defaultAddress;

  @Column(nullable = false, precision = 10, scale = 7)
  private BigDecimal latitude;

  @Column(nullable = false, precision = 10, scale = 7)
  private BigDecimal longitude;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt;

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt;

  protected AddressEntity() {}

  public AddressEntity(UUID id, String ownerUid) {
    this.id = id;
    this.ownerUid = ownerUid;
    this.addressLine2 = "";
    this.landmark = "";
    this.defaultAddress = false;
    this.latitude = BigDecimal.ZERO;
    this.longitude = BigDecimal.ZERO;
    this.createdAt = Instant.now();
    this.updatedAt = this.createdAt;
  }

  public UUID getId() { return id; }
  public String getOwnerUid() { return ownerUid; }
  public String getFullName() { return fullName; }
  public String getPhone() { return phone; }
  public String getAddressLine1() { return addressLine1; }
  public String getAddressLine2() { return addressLine2; }
  public String getCity() { return city; }
  public String getState() { return state; }
  public String getPostalCode() { return postalCode; }
  public String getLandmark() { return landmark; }
  public String getAddressType() { return addressType; }
  public boolean isDefaultAddress() { return defaultAddress; }
  public BigDecimal getLatitude() { return latitude; }
  public BigDecimal getLongitude() { return longitude; }
  public Instant getCreatedAt() { return createdAt; }
  public Instant getUpdatedAt() { return updatedAt; }

  public void update(
      String fullName,
      String phone,
      String addressLine1,
      String addressLine2,
      String city,
      String state,
      String postalCode,
      String landmark,
      String addressType,
      BigDecimal latitude,
      BigDecimal longitude) {
    this.fullName = fullName;
    this.phone = phone;
    this.addressLine1 = addressLine1;
    this.addressLine2 = addressLine2;
    this.city = city;
    this.state = state;
    this.postalCode = postalCode;
    this.landmark = landmark;
    this.addressType = addressType;
    this.latitude = latitude;
    this.longitude = longitude;
    this.updatedAt = Instant.now();
  }

  public void setDefaultAddress(boolean value) {
    this.defaultAddress = value;
    this.updatedAt = Instant.now();
  }
}
