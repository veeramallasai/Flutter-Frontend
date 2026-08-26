package com.farmtohome.api.auth;

import com.farmtohome.api.common.ApiResponse;
import jakarta.validation.Valid;
import java.security.Principal;
import java.util.Map;
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
  ApiResponse<Map<String, Object>> send(Principal principal) {
    return ApiResponse.ok(service.send(principal.getName()), "Email OTP sent.");
  }

  @PostMapping("/verify")
  ApiResponse<Map<String, Object>> verify(
      Principal principal,
      @Valid @RequestBody EmailOtpDtos.VerifyRequest request) {
    return ApiResponse.ok(
        service.verify(principal.getName(), request.otp()),
        "Email verified successfully.");
  }

  @GetMapping("/status")
  ApiResponse<Map<String, Object>> status(Principal principal) {
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
}
