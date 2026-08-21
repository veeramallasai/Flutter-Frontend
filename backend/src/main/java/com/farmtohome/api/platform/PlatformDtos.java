package com.farmtohome.api.platform;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;

public final class PlatformDtos {
  private PlatformDtos() {}

  public record ReviewRequest(
      @NotBlank @Size(max = 180) String userName,
      @NotNull @DecimalMin("1.0") @DecimalMax("5.0") BigDecimal rating,
      @Size(max = 1500) String comment,
      @Size(max = 5) List<@Size(max = 500) String> images) {}

  public record DeliveryPartnerReviewRequest(
      @NotNull @DecimalMin("1.0") @DecimalMax("5.0") BigDecimal rating,
      @Size(max = 1500) String comment) {}

  public record SupportRequest(
      @NotBlank @Size(max = 220) String subject,
      @NotBlank @Size(max = 2500) String message,
      @Size(max = 60) String category,
      @Size(max = 40) String priority) {}

  public record DeviceRequest(
      @NotBlank @Size(max = 1000) String token,
      @Size(max = 30) String platform,
      @Size(max = 180) String deviceName) {}

  public record NotificationPreferencesRequest(
      @NotNull Boolean orderUpdates,
      @NotNull Boolean offers) {}
}
