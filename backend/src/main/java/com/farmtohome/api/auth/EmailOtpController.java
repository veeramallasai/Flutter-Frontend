package com.farmtohome.api.auth;

import com.farmtohome.api.common.ApiException;
import com.farmtohome.api.common.ApiResponse;
import jakarta.validation.Valid;
import java.security.Principal;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth/email-otp")
public class EmailOtpController {
  private final EmailOtpService service;

  public EmailOtpController(EmailOtpService service) {
    this.service = service;
  }

  @PostMapping("/send")
  ApiResponse<Map<String, Object>> send(
      Principal principal,
      @RequestBody(required = false) Map<String, String> body) {
    if (principal != null && principal.getName() != null && !principal.getName().isBlank()) {
      return ApiResponse.ok(service.send(principal.getName()), "Email OTP sent.");
    }
    String email = body != null ? body.get("email") : null;
    if (email != null && !email.isBlank()) {
      return ApiResponse.ok(service.sendForEmail(email), "Email OTP sent.");
    }
    throw new ApiException(HttpStatus.BAD_REQUEST, "Email address or authentication is required.");
  }

  @PostMapping("/verify")
  ApiResponse<Map<String, Object>> verify(
      Principal principal,
      @RequestBody(required = false) Map<String, String> body) {
    String otp = body != null ? body.get("otp") : null;
    String email = body != null ? body.get("email") : null;
    if (principal != null && principal.getName() != null && !principal.getName().isBlank()) {
      return ApiResponse.ok(
          service.verify(principal.getName(), otp),
          "Email verified successfully.");
    }
    if (email != null && !email.isBlank() && otp != null && !otp.isBlank()) {
      return ApiResponse.ok(
          service.verifyForEmail(email, otp),
          "Email verified successfully.");
    }
    throw new ApiException(HttpStatus.BAD_REQUEST, "Email address, OTP, or authentication is required.");
  }

  @GetMapping("/status")
  ApiResponse<Map<String, Object>> status(Principal principal) {
    if (principal == null || principal.getName() == null || principal.getName().isBlank()) {
      return ApiResponse.ok(Map.of("verified", false, "authenticated", false));
    }
    return ApiResponse.ok(service.status(principal.getName()));
  }

  @PostMapping("/request")
  ApiResponse<Map<String, Object>> request(
      @Valid @RequestBody EmailOtpDtos.RequestOtpRequest request) {
    return ApiResponse.ok(
        service.sendForEmail(request.email()),
        "Email OTP sent.");
  }

  @PostMapping("/verify-reset")
  ApiResponse<Map<String, Object>> verifyReset(
      @Valid @RequestBody EmailOtpDtos.VerifyResetRequest request) {
    return ApiResponse.ok(
        service.verifyForEmail(request.email(), request.otp()),
        "Email verified successfully.");
  }

  @GetMapping("/test-smtp")
  ApiResponse<Map<String, Object>> testSmtpGet() {
    return ApiResponse.ok(service.testSmtpConnection(), "SMTP connection status evaluated.");
  }

  @PostMapping("/test-smtp")
  ApiResponse<Map<String, Object>> testSmtpPost() {
    return ApiResponse.ok(service.testSmtpConnection(), "SMTP connection status evaluated.");
  }
}

