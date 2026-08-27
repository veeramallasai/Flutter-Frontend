package com.farmtohome.api.user;

import com.farmtohome.api.common.ApiException;
import java.time.Instant;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AppUserService {
  private final AppUserRepository users;

  public AppUserService(AppUserRepository users) {
    this.users = users;
  }

  @Transactional
  AppUserDtos.Profile sync(String userId, AppUserDtos.SyncRequest request) {
    String uid = text(userId);
    if (uid.isEmpty()) {
      throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid login session.");
    }

    Instant now = Instant.now();
    boolean created = !users.existsById(uid);
    AppUserEntity user = users.findById(uid).orElseGet(AppUserEntity::new);
    if (created) {
      user.setFirebaseUid(uid);
      user.setEmail("");
      user.setFirstName("");
      user.setLastName("");
      user.setDisplayName("");
      user.setPhoneNumber("");
      user.setPhotoUrl("");
      user.setShoppingMode("home");
      user.setAccountType("customer");
      user.setAuthProvider("email");
      user.setCreatedAt(now);
      user.setActive(true);
    }

    String firstName = preferred(request.firstName(), user.getFirstName());
    String lastName = preferred(request.lastName(), user.getLastName());
    String displayName = (firstName + " " + lastName).trim();
    if (displayName.isEmpty()) displayName = user.getDisplayName();

    user.setFirstName(firstName);
    user.setLastName(lastName);
    if (!displayName.isEmpty()) {
      user.setDisplayName(displayName);
    }
    user.setPhoneNumber(preferred(request.phoneNumber(), user.getPhoneNumber()));
    user.setPhotoUrl(preferred(request.photoUrl(), user.getPhotoUrl()));
    user.setShoppingMode(choice(request.shoppingMode(), user.getShoppingMode(), "home", "shop"));
    user.setAccountType(choice(request.accountType(), user.getAccountType(), "customer", "shop_owner"));
    user.setActive(true);
    user.setLastLoginAt(now);
    user.setUpdatedAt(now);

    try {
      return AppUserDtos.Profile.from(users.saveAndFlush(user));
    } catch (DataIntegrityViolationException error) {
      throw new ApiException(
          HttpStatus.CONFLICT,
          "This email address or mobile number is already linked to another account.");
    }
  }

  @Transactional(readOnly = true)
  AppUserDtos.Profile get(String uid) {
    return users.findById(uid)
        .map(AppUserDtos.Profile::from)
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User profile not found."));
  }

  private static String choice(Object requested, Object current, String first, String second) {
    String value = text(requested).toLowerCase();
    if (value.equals(first) || value.equals(second)) return value;
    value = text(current).toLowerCase();
    return value.equals(second) ? second : first;
  }

  private static String preferred(Object primary, Object fallback) {
    String value = text(primary);
    return value.isEmpty() ? text(fallback) : value;
  }

  private static String text(Object value) {
    return value == null ? "" : value.toString().trim();
  }
}
