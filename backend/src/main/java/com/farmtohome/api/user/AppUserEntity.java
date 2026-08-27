package com.farmtohome.api.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "app_users")
public class AppUserEntity {
  @Id
  @Column(name = "firebase_uid", nullable = false, length = 160)
  private String firebaseUid;

  @Column(name = "first_name", nullable = false, length = 100)
  private String firstName;

  @Column(name = "last_name", nullable = false, length = 100)
  private String lastName;

  @Column(name = "display_name", nullable = false, length = 220)
  private String displayName;

  @Column(nullable = false, length = 320)
  private String email;

  @Column(name = "phone_number", nullable = false, length = 32)
  private String phoneNumber;

  @Column(name = "photo_url", nullable = false, length = 1000)
  private String photoUrl;

  @Column(name = "shopping_mode", nullable = false, length = 20)
  private String shoppingMode;

  @Column(name = "account_type", nullable = false, length = 40)
  private String accountType;

  @Column(name = "auth_provider", nullable = false, length = 80)
  private String authProvider;

  @Column(name = "email_verified", nullable = false)
  private boolean emailVerified;

  @Column(name = "phone_verified", nullable = false)
  private boolean phoneVerified;

  @Column(nullable = false)
  private boolean active;

  @Column(name = "last_login_at", nullable = false)
  private Instant lastLoginAt;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt;

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt;

  public AppUserEntity() {}

  public String getFirebaseUid() { return firebaseUid; }
  public void setFirebaseUid(String firebaseUid) { this.firebaseUid = firebaseUid; }
  public String getFirstName() { return firstName; }
  public void setFirstName(String firstName) { this.firstName = firstName; }
  public String getLastName() { return lastName; }
  public void setLastName(String lastName) { this.lastName = lastName; }
  public String getDisplayName() { return displayName; }
  public void setDisplayName(String displayName) { this.displayName = displayName; }
  public String getEmail() { return email; }
  public void setEmail(String email) { this.email = email; }
  public String getPhoneNumber() { return phoneNumber; }
  public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
  public String getPhotoUrl() { return photoUrl; }
  public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
  public String getShoppingMode() { return shoppingMode; }
  public void setShoppingMode(String shoppingMode) { this.shoppingMode = shoppingMode; }
  public String getAccountType() { return accountType; }
  public void setAccountType(String accountType) { this.accountType = accountType; }
  public String getAuthProvider() { return authProvider; }
  public void setAuthProvider(String authProvider) { this.authProvider = authProvider; }
  public boolean isEmailVerified() { return emailVerified; }
  public void setEmailVerified(boolean emailVerified) { this.emailVerified = emailVerified; }
  public boolean isPhoneVerified() { return phoneVerified; }
  public void setPhoneVerified(boolean phoneVerified) { this.phoneVerified = phoneVerified; }
  public boolean isActive() { return active; }
  public void setActive(boolean active) { this.active = active; }
  public Instant getLastLoginAt() { return lastLoginAt; }
  public void setLastLoginAt(Instant lastLoginAt) { this.lastLoginAt = lastLoginAt; }
  public Instant getCreatedAt() { return createdAt; }
  public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
  public Instant getUpdatedAt() { return updatedAt; }
  public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
