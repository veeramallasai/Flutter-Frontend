package com.farmtohome.api.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public final class EmailOtpDtos {
  private EmailOtpDtos() {}

  public record VerifyRequest(
      @NotBlank
      @Pattern(regexp = "\\d{6}", message = "OTP must be exactly 6 digits.")
      String otp) {}

  public record RequestOtpRequest(
      @NotBlank(message = "Email is required.")
      @Email(message = "Enter a valid email address.")
      String email) {}

  public record VerifyResetRequest(
      @NotBlank(message = "Email is required.")
      @Email(message = "Enter a valid email address.")
      String email,

      @NotBlank
      @Pattern(regexp = "\\d{6}", message = "OTP must be exactly 6 digits.")
      String otp) {}
}
