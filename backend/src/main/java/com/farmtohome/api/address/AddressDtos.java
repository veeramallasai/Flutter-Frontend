package com.farmtohome.api.address;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.Instant;

public final class AddressDtos {
  private AddressDtos() {}

  public record SaveRequest(
      @NotBlank @Size(max = 160) String fullName,
      @NotBlank @Pattern(regexp = "^[+]?[0-9 ]{10,16}$") String phone,
      @NotBlank @Size(max = 300) String addressLine1,
      @Size(max = 300) String addressLine2,
      @NotBlank @Size(max = 120) String city,
      @NotBlank @Size(max = 120) String state,
      @NotBlank @Pattern(regexp = "^[0-9]{6}$") String postalCode,
      @Size(max = 200) String landmark,
      @NotBlank String type,
      boolean isDefault,
      @DecimalMin("-90.0") @DecimalMax("90.0") BigDecimal latitude,
      @DecimalMin("-180.0") @DecimalMax("180.0") BigDecimal longitude) {}

  public record Address(
      String id,
      String userId,
      String fullName,
      String phone,
      String addressLine1,
      String addressLine2,
      String city,
      String state,
      String postalCode,
      String landmark,
      String type,
      boolean isDefault,
      BigDecimal latitude,
      BigDecimal longitude,
      Instant createdAt,
      Instant updatedAt) {}
}
