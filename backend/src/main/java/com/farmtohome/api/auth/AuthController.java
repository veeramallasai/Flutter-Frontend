package com.farmtohome.api.auth;

import com.farmtohome.api.common.ApiException;
import com.farmtohome.api.common.ApiResponse;
import com.farmtohome.api.user.AppUserEntity;
import com.farmtohome.api.user.AppUserRepository;
import jakarta.validation.Valid;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
  private static final Logger log = LoggerFactory.getLogger(AuthController.class);

  private final AppUserRepository userRepository;
  private final EmailOtpService emailOtpService;
  private final ProviderIdentityTokenVerifier identityTokenVerifier;
  private final JwtTokenService jwtTokenService;

  public AuthController(
      AppUserRepository userRepository,
      EmailOtpService emailOtpService,
      ProviderIdentityTokenVerifier identityTokenVerifier,
      JwtTokenService jwtTokenService) {
    this.userRepository = userRepository;
    this.emailOtpService = emailOtpService;
    this.identityTokenVerifier = identityTokenVerifier;
    this.jwtTokenService = jwtTokenService;
  }

  @PostMapping("/login")
  public ApiResponse<AuthDtos.AuthResponse> login(
      @Valid @RequestBody AuthDtos.LoginRequest request) {
    String email = request.email().trim().toLowerCase();
    Optional<AppUserEntity> entity = userRepository.findByEmail(email);
    if (entity.isEmpty()) {
      throw new ApiException(HttpStatus.UNAUTHORIZED, "The email or password is incorrect.");
    }
    AppUserEntity u = entity.get();
    return processUserLogin(u.getFirebaseUid(), email, u.getDisplayName(), u.getPhotoUrl());
  }

  @PostMapping("/register")
  public ApiResponse<AuthDtos.AuthResponse> register(
      @Valid @RequestBody AuthDtos.RegisterRequest request) {
    String email = request.email().trim().toLowerCase();

    Optional<AppUserEntity> existingUser = userRepository.findByEmail(email);
    if (existingUser.isPresent()) {
      AppUserEntity existing = existingUser.get();
      return processUserLogin(existing.getFirebaseUid(), email, existing.getDisplayName(), existing.getPhotoUrl());
    }

    String uid = "usr_" + UUID.randomUUID().toString().replace("-", "").substring(0, 16);

    String firstName = request.firstName() != null ? request.firstName().trim() : "";
    String lastName = request.lastName() != null ? request.lastName().trim() : "";
    String name = (firstName + " " + lastName).trim();
    if (name.isEmpty()) name = email.split("@")[0];

    AppUserEntity entity = new AppUserEntity();
    entity.setFirebaseUid(uid);
    entity.setEmail(email);
    entity.setFirstName(firstName);
    entity.setLastName(lastName);
    entity.setDisplayName(name);
    entity.setPhoneNumber("");
    entity.setPhotoUrl("");
    entity.setShoppingMode("home");
    entity.setAccountType("customer");
    entity.setAuthProvider("password");
    entity.setActive(true);
    entity.setCreatedAt(Instant.now());
    entity.setUpdatedAt(Instant.now());
    entity.setLastLoginAt(Instant.now());

    try {
      userRepository.save(entity);
    } catch (org.springframework.dao.DataIntegrityViolationException e) {
      Optional<AppUserEntity> retry = userRepository.findByEmail(email);
      if (retry.isPresent()) {
        AppUserEntity existing = retry.get();
        return processUserLogin(existing.getFirebaseUid(), email, existing.getDisplayName(), existing.getPhotoUrl());
      }
      throw new ApiException(HttpStatus.CONFLICT, "An account already exists with this email.");
    }

    return processUserLogin(uid, email, entity.getDisplayName(), entity.getPhotoUrl());
  }

  @PostMapping("/google-login")
  public ApiResponse<AuthDtos.AuthResponse> googleLogin(
      @Valid @RequestBody AuthDtos.GoogleLoginRequest request) {
    return loginProvider(
        identityTokenVerifier.verifyGoogle(request.idToken()),
        "google.com", null, null);
  }

  @PostMapping("/apple-login")
  public ApiResponse<AuthDtos.AuthResponse> appleLogin(
      @Valid @RequestBody AuthDtos.AppleLoginRequest request) {
    return loginProvider(
        identityTokenVerifier.verifyApple(request.idToken(), request.rawNonce()),
        "apple.com", request.firstName(), request.lastName());
  }

      @PostMapping("/apple/callback")
      public ResponseEntity<Void> appleAndroidCallback(
        @RequestParam MultiValueMap<String, String> parameters) {
      String query = parameters.entrySet().stream()
        .flatMap(entry -> entry.getValue().stream().map(value ->
          encode(entry.getKey()) + "=" + encode(value)))
        .reduce((left, right) -> left + "&" + right)
        .orElse("");
      String location = "intent://callback?" + query
        + "#Intent;package=com.example.farm_to_home_app;scheme=signinwithapple;end";
      return ResponseEntity.status(HttpStatus.FOUND)
        .header(HttpHeaders.LOCATION, location)
        .build();
      }

  @PostMapping("/forgot-password")
  public ApiResponse<Map<String, Object>> forgotPassword(
      @Valid @RequestBody AuthDtos.ForgotPasswordRequest request) {
    log.info("[API] POST /auth/forgot-password for email: {}", request.email());
    Map<String, Object> response = emailOtpService.sendForEmail(request.email().trim().toLowerCase());
    return ApiResponse.ok(response, "Password reset OTP sent to email.");
  }

  @PostMapping("/reset-password")
  public ApiResponse<Map<String, Object>> resetPassword(
      @Valid @RequestBody AuthDtos.ResetPasswordRequest request) {
    log.info("[API] POST /auth/reset-password for email: {}", request.email());
    Map<String, Object> response = emailOtpService.verifyForEmail(
        request.email().trim().toLowerCase(), request.otpCode().trim());

    return ApiResponse.ok(response, "Password reset successfully.");
  }

  private ApiResponse<AuthDtos.AuthResponse> processUserLogin(
      String uid, String email, String name, String photoUrl) {
    String token = jwtTokenService.issue(uid, email);

    userRepository.findById(uid).ifPresent(user -> {
      user.setLastLoginAt(Instant.now());
      userRepository.save(user);
    });

    AuthDtos.AuthResponse response = new AuthDtos.AuthResponse(
        token, uid, email, name != null ? name : email.split("@")[0], photoUrl);
    return ApiResponse.ok(response, "Authentication successful.");
  }

  private static String encode(String value) {
    return URLEncoder.encode(value, StandardCharsets.UTF_8);
  }

  private ApiResponse<AuthDtos.AuthResponse> loginProvider(
      ProviderIdentityTokenVerifier.ProviderIdentity identity,
      String provider,
      String suppliedFirstName,
      String suppliedLastName) {
    Optional<AppUserEntity> existingUser = userRepository.findByEmail(identity.email());
    if (existingUser.isPresent()) {
      AppUserEntity existing = existingUser.get();
      existing.setLastLoginAt(Instant.now());
      existing.setUpdatedAt(Instant.now());
      existing.setEmailVerified(true);
      if (identity.picture() != null && !identity.picture().isBlank()) {
        existing.setPhotoUrl(identity.picture());
      }
      userRepository.save(existing);
      return processUserLogin(
          existing.getFirebaseUid(), identity.email(),
          existing.getDisplayName(), existing.getPhotoUrl());
    }

    String fullName = identity.name() == null ? "" : identity.name().trim();
    String firstName = suppliedFirstName == null ? "" : suppliedFirstName.trim();
    String lastName = suppliedLastName == null ? "" : suppliedLastName.trim();
    if (fullName.isBlank()) fullName = (firstName + " " + lastName).trim();
    if (fullName.isBlank()) fullName = identity.email().split("@")[0];
    if (firstName.isBlank() && lastName.isBlank()) {
      String[] names = fullName.split("\\s+", 2);
      firstName = names[0];
      lastName = names.length > 1 ? names[1] : "";
    }

    AppUserEntity entity = new AppUserEntity();
    entity.setFirebaseUid(provider.replace(".com", "") + "_" + identity.subject());
    entity.setEmail(identity.email());
    entity.setFirstName(firstName);
    entity.setLastName(lastName);
    entity.setDisplayName(fullName);
    entity.setPhoneNumber("");
    entity.setPhotoUrl(identity.picture() == null ? "" : identity.picture());
    entity.setShoppingMode("home");
    entity.setAccountType("customer");
    entity.setAuthProvider(provider);
    entity.setEmailVerified(true);
    entity.setActive(true);
    entity.setCreatedAt(Instant.now());
    entity.setUpdatedAt(Instant.now());
    entity.setLastLoginAt(Instant.now());

    try {
      userRepository.save(entity);
    } catch (org.springframework.dao.DataIntegrityViolationException error) {
      AppUserEntity existing = userRepository.findByEmail(identity.email())
          .orElseThrow(() -> error);
      return processUserLogin(
          existing.getFirebaseUid(), identity.email(),
          existing.getDisplayName(), existing.getPhotoUrl());
    }
    return processUserLogin(
        entity.getFirebaseUid(), identity.email(), entity.getDisplayName(), entity.getPhotoUrl());
  }

}
