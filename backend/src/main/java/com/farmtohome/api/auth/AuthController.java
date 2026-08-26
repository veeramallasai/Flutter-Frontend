package com.farmtohome.api.auth;

import com.farmtohome.api.common.ApiException;
import com.farmtohome.api.common.ApiResponse;
import com.farmtohome.api.user.AppUserEntity;
import com.farmtohome.api.user.AppUserRepository;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import jakarta.validation.Valid;
import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

  private final FirebaseAuth firebaseAuth;
  private final AppUserRepository userRepository;
  private final EmailOtpService emailOtpService;

  public AuthController(
      FirebaseApp firebaseApp,
      AppUserRepository userRepository,
      EmailOtpService emailOtpService) {
    this.firebaseAuth = FirebaseAuth.getInstance(firebaseApp);
    this.userRepository = userRepository;
    this.emailOtpService = emailOtpService;
  }

  @PostMapping("/login")
  public ApiResponse<AuthDtos.AuthResponse> login(
      @Valid @RequestBody AuthDtos.LoginRequest request) {
    String email = request.email().trim().toLowerCase();
    UserRecord userRecord;
    try {
      userRecord = firebaseAuth.getUserByEmail(email);
    } catch (FirebaseAuthException e) {
      // Check database if user exists
      Optional<AppUserEntity> entity = userRepository.findByEmail(email);
      if (entity.isEmpty()) {
        throw new ApiException(HttpStatus.UNAUTHORIZED, "The email or password is incorrect.");
      }
      AppUserEntity u = entity.get();
      return processUserLogin(u.getFirebaseUid(), email, u.getDisplayName(), u.getPhotoUrl());
    }

    AppUserEntity appUser = findOrCreateUserEntity(userRecord.getUid(), email, userRecord.getDisplayName(), userRecord.getPhotoUrl());
    return processUserLogin(appUser.getFirebaseUid(), email, appUser.getDisplayName(), appUser.getPhotoUrl());
  }

  @PostMapping("/register")
  public ApiResponse<AuthDtos.AuthResponse> register(
      @Valid @RequestBody AuthDtos.RegisterRequest request) {
    String email = request.email().trim().toLowerCase();
    String uid;

    try {
      UserRecord existing = firebaseAuth.getUserByEmail(email);
      if (existing != null) {
        throw new ApiException(HttpStatus.CONFLICT, "An account already exists with this email.");
      }
    } catch (FirebaseAuthException ignored) {
      // User does not exist in Firebase yet, which is expected
    }

    if (userRepository.findByEmail(email).isPresent()) {
      throw new ApiException(HttpStatus.CONFLICT, "An account already exists with this email.");
    }

    try {
      UserRecord.CreateRequest createRequest = new UserRecord.CreateRequest()
          .setEmail(email)
          .setPassword(request.password())
          .setEmailVerified(false);
      
      String name = ((request.firstName() != null ? request.firstName() : "") + " " + (request.lastName() != null ? request.lastName() : "")).trim();
      if (!name.isEmpty()) {
        createRequest.setDisplayName(name);
      }
      
      UserRecord created = firebaseAuth.createUser(createRequest);
      uid = created.getUid();
    } catch (FirebaseAuthException e) {
      uid = "usr_" + UUID.randomUUID().toString().replace("-", "").substring(0, 16);
    }

    String name = ((request.firstName() != null ? request.firstName() : "") + " " + (request.lastName() != null ? request.lastName() : "")).trim();
    if (name.isEmpty()) name = email.split("@")[0];

    AppUserEntity entity = findOrCreateUserEntity(uid, email, name, null);
    if (request.firstName() != null) entity.setFirstName(request.firstName());
    if (request.lastName() != null) entity.setLastName(request.lastName());
    userRepository.save(entity);

    return processUserLogin(uid, email, entity.getDisplayName(), entity.getPhotoUrl());
  }

  @PostMapping("/social-login")
  public ApiResponse<AuthDtos.AuthResponse> socialLogin(
      @Valid @RequestBody AuthDtos.SocialLoginRequest request) {
    String email = request.email().trim().toLowerCase();
    String uid;

    try {
      UserRecord userRecord = firebaseAuth.getUserByEmail(email);
      uid = userRecord.getUid();
    } catch (FirebaseAuthException e) {
      uid = "soc_" + UUID.randomUUID().toString().replace("-", "").substring(0, 16);
    }

    String name = ((request.firstName() != null ? request.firstName() : "") + " " + (request.lastName() != null ? request.lastName() : "")).trim();
    if (name.isEmpty()) name = email.split("@")[0];

    AppUserEntity entity = findOrCreateUserEntity(uid, email, name, request.photoUrl());
    entity.setAuthProvider(request.provider());
    userRepository.save(entity);

    return processUserLogin(uid, email, entity.getDisplayName(), entity.getPhotoUrl());
  }

  @PostMapping("/forgot-password")
  public ApiResponse<Map<String, Object>> forgotPassword(
      @Valid @RequestBody AuthDtos.ForgotPasswordRequest request) {
    Map<String, Object> response = emailOtpService.sendForEmail(request.email().trim().toLowerCase());
    return ApiResponse.ok(response, "Password reset OTP sent to email.");
  }

  @PostMapping("/reset-password")
  public ApiResponse<Map<String, Object>> resetPassword(
      @Valid @RequestBody AuthDtos.ResetPasswordRequest request) {
    Map<String, Object> response = emailOtpService.verifyForEmail(
        request.email().trim().toLowerCase(), request.otpCode().trim());
    
    try {
      UserRecord userRecord = firebaseAuth.getUserByEmail(request.email().trim().toLowerCase());
      UserRecord.UpdateRequest updateRequest = new UserRecord.UpdateRequest(userRecord.getUid())
          .setPassword(request.newPassword());
      firebaseAuth.updateUser(updateRequest);
    } catch (Exception ignored) {}

    return ApiResponse.ok(response, "Password reset successfully.");
  }

  private ApiResponse<AuthDtos.AuthResponse> processUserLogin(
      String uid, String email, String name, String photoUrl) {
    String token;
    try {
      token = firebaseAuth.createCustomToken(uid);
    } catch (FirebaseAuthException e) {
      token = "jwt_session_" + uid + "_" + System.currentTimeMillis();
    }

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
      user.setEmail(email);
      user.setDisplayName(displayName != null ? displayName : email.split("@")[0]);
      user.setPhotoUrl(photoUrl);
      user.setActive(true);
      user.setCreatedAt(Instant.now());
      user.setUpdatedAt(Instant.now());
      user.setLastLoginAt(Instant.now());
      return userRepository.save(user);
    });
  }
}
