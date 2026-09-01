package com.farmtohome.api.auth;

import com.farmtohome.api.common.ApiException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.HexFormat;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.JwtTimestampValidator;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.stereotype.Service;

@Service
public class ProviderIdentityTokenVerifier {
  private static final OAuth2Error INVALID_TOKEN =
      new OAuth2Error("invalid_token", "Identity token validation failed.", null);

  private final JwtDecoder googleDecoder;
  private final JwtDecoder appleDecoder;

  public ProviderIdentityTokenVerifier(
      @Value("${app.auth.google-client-ids}") String googleClientIds,
      @Value("${app.auth.apple-client-ids}") String appleClientIds) {
    this.googleDecoder = providerDecoder(
        "https://www.googleapis.com/oauth2/v3/certs",
        List.of("https://accounts.google.com", "accounts.google.com"),
        split(googleClientIds));
    this.appleDecoder = providerDecoder(
        "https://appleid.apple.com/auth/keys",
        List.of("https://appleid.apple.com"),
        split(appleClientIds));
  }

  public ProviderIdentity verifyGoogle(String token) {
    Jwt jwt = decode(googleDecoder, token, "Google");
    if (!isTrue(jwt.getClaim("email_verified"))) {
      throw unauthorized("Google email is not verified.");
    }
    return identity(jwt);
  }

  public ProviderIdentity verifyApple(String token, String rawNonce) {
    Jwt jwt = decode(appleDecoder, token, "Apple");
    if (!isTrue(jwt.getClaim("email_verified"))) {
      throw unauthorized("Apple email is not verified.");
    }
    if (rawNonce == null || rawNonce.isBlank()) {
      throw unauthorized("Apple nonce is required.");
    }
    String expectedNonce = sha256(rawNonce);
    if (!MessageDigest.isEqual(
        expectedNonce.getBytes(StandardCharsets.UTF_8),
        String.valueOf(jwt.getClaim("nonce")).getBytes(StandardCharsets.UTF_8))) {
      throw unauthorized("Apple nonce validation failed.");
    }
    return identity(jwt);
  }

  private JwtDecoder providerDecoder(String jwkSetUri, List<String> issuers, List<String> audiences) {
    NimbusJwtDecoder decoder = NimbusJwtDecoder.withJwkSetUri(jwkSetUri).build();
    OAuth2TokenValidator<Jwt> issuer = jwt -> jwt.getIssuer() != null
      && issuers.contains(jwt.getIssuer().toString())
        ? OAuth2TokenValidatorResult.success()
        : OAuth2TokenValidatorResult.failure(INVALID_TOKEN);
    OAuth2TokenValidator<Jwt> audience = jwt -> jwt.getAudience().stream().anyMatch(audiences::contains)
        ? OAuth2TokenValidatorResult.success()
        : OAuth2TokenValidatorResult.failure(INVALID_TOKEN);
    decoder.setJwtValidator(new DelegatingOAuth2TokenValidator<>(
        new JwtTimestampValidator(), issuer, audience));
    return decoder;
  }

  private Jwt decode(JwtDecoder decoder, String token, String provider) {
    if (token == null || token.isBlank()) {
      throw unauthorized(provider + " identity token is required.");
    }
    try {
      return decoder.decode(token);
    } catch (JwtException error) {
      throw unauthorized("Invalid or expired " + provider + " identity token.");
    }
  }

  private ProviderIdentity identity(Jwt jwt) {
    if (jwt.getSubject() == null || jwt.getSubject().isBlank()) {
      throw unauthorized("Verified identity token does not contain a subject.");
    }
    String email = jwt.getClaimAsString("email");
    if (email == null || email.isBlank()) {
      throw unauthorized("Verified identity token does not contain an email address.");
    }
    return new ProviderIdentity(
        jwt.getSubject(), email.trim().toLowerCase(),
        jwt.getClaimAsString("name"), jwt.getClaimAsString("picture"));
  }

  private static boolean isTrue(Object value) {
    return Boolean.TRUE.equals(value) || "true".equalsIgnoreCase(String.valueOf(value));
  }

  private static List<String> split(String value) {
    List<String> values = Arrays.stream(value.split(","))
        .map(String::trim).filter(item -> !item.isEmpty()).toList();
    if (values.isEmpty()) throw new IllegalStateException("OAuth client IDs must be configured.");
    return values;
  }

  private static String sha256(String value) {
    try {
      return HexFormat.of().formatHex(
          MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8)));
    } catch (Exception error) {
      throw new IllegalStateException("SHA-256 is unavailable.", error);
    }
  }

  private static ApiException unauthorized(String message) {
    return new ApiException(HttpStatus.UNAUTHORIZED, message);
  }

  public record ProviderIdentity(String subject, String email, String name, String picture) {}
}