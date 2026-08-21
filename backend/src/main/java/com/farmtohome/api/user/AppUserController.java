package com.farmtohome.api.user;

import com.farmtohome.api.common.ApiException;
import com.farmtohome.api.common.ApiResponse;
import com.google.firebase.auth.FirebaseToken;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
public class AppUserController {
  private final AppUserService users;

  public AppUserController(AppUserService users) {
    this.users = users;
  }

  @PutMapping("/me")
  ApiResponse<AppUserDtos.Profile> sync(
      Authentication authentication,
      @Valid @RequestBody AppUserDtos.SyncRequest request) {
    return ApiResponse.ok(users.sync(token(authentication), request), "Profile synchronized.");
  }

  @GetMapping("/me")
  ApiResponse<AppUserDtos.Profile> me(Authentication authentication) {
    return ApiResponse.ok(users.get(authentication.getName()));
  }

  private FirebaseToken token(Authentication authentication) {
    Object value = authentication == null ? null : authentication.getCredentials();
    if (value instanceof FirebaseToken firebaseToken) return firebaseToken;
    throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid login session.");
  }
}
