package com.farmtohome.api.user;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.Instant;

public final class AppUserDtos {
  private AppUserDtos() {}

  public record SyncRequest(
      @Size(max = 100) String firstName,
      @Size(max = 100) String lastName,
      @Size(max = 32) String phoneNumber,
      @Size(max = 1000) String photoUrl,
      @Pattern(regexp = "home|shop") String shoppingMode,
      @Pattern(regexp = "customer|shop_owner") String accountType) {}

  public record Profile(
      String firebaseUid,
      String firstName,
      String lastName,
      String displayName,
      String email,
      String phoneNumber,
      String photoUrl,
      String shoppingMode,
      String accountType,
      String authProvider,
      boolean emailVerified,
      boolean phoneVerified,
      boolean active,
      Instant lastLoginAt,
      Instant createdAt,
      Instant updatedAt) {
    static Profile from(AppUserEntity value) {
      return new Profile(
          value.getFirebaseUid(), value.getFirstName(), value.getLastName(),
          value.getDisplayName(), value.getEmail(), value.getPhoneNumber(),
          value.getPhotoUrl(), value.getShoppingMode(), value.getAccountType(),
          value.getAuthProvider(), value.isEmailVerified(), value.isPhoneVerified(),
          value.isActive(), value.getLastLoginAt(), value.getCreatedAt(),
          value.getUpdatedAt());
    }
  }
}
