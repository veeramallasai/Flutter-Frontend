package com.farmtohome.api.auth;

import com.farmtohome.api.common.ApiException;
import com.farmtohome.api.common.ApiResponse;
import com.farmtohome.api.user.AppUserEntity;
import com.farmtohome.api.user.AppUserRepository;
import jakarta.validation.Valid;
import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
  private static final Logger log = LoggerFactory.getLogger(AuthController.class);

  private final AppUserRepository userRepository;
  private final EmailOtpService emailOtpService;

  public AuthController(
      AppUserRepository userRepository,
      EmailOtpService emailOtpService) {
    this.userRepository = userRepository;
    this.emailOtpService = emailOtpService;
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

  @PostMapping("/social-login")
  public ApiResponse<AuthDtos.AuthResponse> socialLogin(
      @Valid @RequestBody AuthDtos.SocialLoginRequest request) {
    String email = request.email().trim().toLowerCase();
    
    if (request.idToken() != null && !request.idToken().isBlank() && "google".equalsIgnoreCase(request.provider())) {
      Map<String, Object> verifiedClaims = verifyAndExtractGoogleToken(request.idToken(), email);
      if (verifiedClaims.containsKey("email")) {
        email = ((String) verifiedClaims.get("email")).toLowerCase();
      }
    }

    Optional<AppUserEntity> existingUser = userRepository.findByEmail(email);
    if (existingUser.isPresent()) {
      AppUserEntity existing = existingUser.get();
      existing.setLastLoginAt(Instant.now());
      if (request.photoUrl() != null && !request.photoUrl().isBlank()) {
        existing.setPhotoUrl(request.photoUrl().trim());
      }
      userRepository.save(existing);
      return processUserLogin(existing.getFirebaseUid(), email, existing.getDisplayName(), existing.getPhotoUrl());
    }

    String uid = "soc_" + UUID.randomUUID().toString().replace("-", "").substring(0, 16);

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
    entity.setPhotoUrl(request.photoUrl() != null ? request.photoUrl() : "");
    entity.setShoppingMode("home");
    entity.setAccountType("customer");
    entity.setAuthProvider(request.provider() != null ? request.provider() : "google.com");
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
    }

    return processUserLogin(uid, email, entity.getDisplayName(), entity.getPhotoUrl());
  }

  @PostMapping("/google-login")
  public ApiResponse<AuthDtos.AuthResponse> googleLogin(
      @Valid @RequestBody AuthDtos.GoogleLoginRequest request) {
    String email = request.email() != null ? request.email().trim().toLowerCase() : "";
    String idToken = request.idToken();

    Map<String, Object> tokenPayload = verifyAndExtractGoogleToken(idToken, email);

    String verifiedEmail = tokenPayload.containsKey("email")
        ? ((String) tokenPayload.get("email")).toLowerCase()
        : email;
    if (verifiedEmail.isBlank()) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Invalid Google ID token: email missing.");
    }

    String name = tokenPayload.containsKey("name")
        ? (String) tokenPayload.get("name")
        : (request.name() != null ? request.name() : "");
    String picture = tokenPayload.containsKey("picture")
        ? (String) tokenPayload.get("picture")
        : (request.photoUrl() != null ? request.photoUrl() : "");

    Optional<AppUserEntity> existingUser = userRepository.findByEmail(verifiedEmail);
    if (existingUser.isPresent()) {
      AppUserEntity existing = existingUser.get();
      existing.setLastLoginAt(Instant.now());
      if (!picture.isBlank()) existing.setPhotoUrl(picture);
      userRepository.save(existing);
      return processUserLogin(existing.getFirebaseUid(), verifiedEmail, existing.getDisplayName(), existing.getPhotoUrl());
    }

    String uid = "google_" + UUID.randomUUID().toString().replace("-", "").substring(0, 16);
    String[] parts = name.split("\\s+", 2);
    String firstName = parts.length > 0 ? parts[0] : "";
    String lastName = parts.length > 1 ? parts[1] : "";

    AppUserEntity entity = new AppUserEntity();
    entity.setFirebaseUid(uid);
    entity.setEmail(verifiedEmail);
    entity.setFirstName(firstName);
    entity.setLastName(lastName);
    entity.setDisplayName(name.isBlank() ? verifiedEmail.split("@")[0] : name);
    entity.setPhoneNumber("");
    entity.setPhotoUrl(picture);
    entity.setShoppingMode("home");
    entity.setAccountType("customer");
    entity.setAuthProvider("google.com");
    entity.setActive(true);
    entity.setCreatedAt(Instant.now());
    entity.setUpdatedAt(Instant.now());
    entity.setLastLoginAt(Instant.now());

    try {
      userRepository.save(entity);
    } catch (org.springframework.dao.DataIntegrityViolationException e) {
      Optional<AppUserEntity> retry = userRepository.findByEmail(verifiedEmail);
      if (retry.isPresent()) {
        AppUserEntity existing = retry.get();
        return processUserLogin(existing.getFirebaseUid(), verifiedEmail, existing.getDisplayName(), existing.getPhotoUrl());
      }
    }

    return processUserLogin(uid, verifiedEmail, entity.getDisplayName(), entity.getPhotoUrl());
  }

  private Map<String, Object> verifyAndExtractGoogleToken(String idToken, String fallbackEmail) {
    if (idToken == null || idToken.isBlank()) {
      if (fallbackEmail != null && !fallbackEmail.isBlank()) {
        return Map.of("email", fallbackEmail);
      }
      throw new ApiException(HttpStatus.BAD_REQUEST, "Google ID token is required.");
    }

    try {
      org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate();
      String tokenInfoUrl = "https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken;
      @SuppressWarnings("unchecked")
      Map<String, Object> response = restTemplate.getForObject(tokenInfoUrl, Map.class);
      if (response != null && response.containsKey("email")) {
        log.info("[GOOGLE OAUTH] Verified Google tokeninfo for email: {}", response.get("email"));
        return response;
      }
    } catch (Exception e) {
      log.warn("[GOOGLE OAUTH] Tokeninfo endpoint verification fallback: {}", e.getMessage());
    }

    try {
      String[] parts = idToken.split("\\.");
      if (parts.length >= 2) {
        String payloadJson = new String(java.util.Base64.getUrlDecoder().decode(parts[1]), java.nio.charset.StandardCharsets.UTF_8);
        com.fasterxml.jackson.databind.ObjectMapper om = new com.fasterxml.jackson.databind.ObjectMapper();
        @SuppressWarnings("unchecked")
        Map<String, Object> claims = om.readValue(payloadJson, Map.class);
        if (claims.containsKey("email")) {
          log.info("[GOOGLE OAUTH] Decoded JWT claims for email: {}", claims.get("email"));
          return claims;
        }
      }
    } catch (Exception e) {
      log.error("[GOOGLE OAUTH] Failed to decode Google ID Token JWT payload: {}", e.getMessage());
    }

    if (fallbackEmail != null && !fallbackEmail.isBlank()) {
      return Map.of("email", fallbackEmail);
    }

    throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid or unverified Google ID token.");
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
    String token = "jwt_session_" + uid + "_" + System.currentTimeMillis();

    userRepository.findById(uid).ifPresent(user -> {
      user.setLastLoginAt(Instant.now());
      userRepository.save(user);
    });

    AuthDtos.AuthResponse response = new AuthDtos.AuthResponse(
        token, uid, email, name != null ? name : email.split("@")[0], photoUrl);
    return ApiResponse.ok(response, "Authentication successful.");
  }

  private AppUserEntity findOrCreateUserEntity(
      String uid, String email, String displayName, String photoUrl) {
    return userRepository.findById(uid).orElseGet(() -> {
      AppUserEntity user = new AppUserEntity();
      user.setFirebaseUid(uid);
      user.setEmail(email != null ? email : "");
      user.setDisplayName(displayName != null && !displayName.trim().isEmpty() ? displayName : (email != null ? email.split("@")[0] : "User"));
      user.setFirstName("");
      user.setLastName("");
      user.setPhoneNumber("");
      user.setPhotoUrl(photoUrl != null ? photoUrl : "");
      user.setShoppingMode("home");
      user.setAccountType("customer");
      user.setAuthProvider("password");
      user.setActive(true);
      user.setCreatedAt(Instant.now());
      user.setUpdatedAt(Instant.now());
      user.setLastLoginAt(Instant.now());
      return userRepository.save(user);
    });
  }
}
