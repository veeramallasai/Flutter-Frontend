package com.farmtohome.api.auth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.JwtException;

class JwtTokenServiceTest {
  private static final String SECRET =
      "test-secret-with-at-least-thirty-two-random-bytes";

  @Test
  void issuedTokenIsVerifiedAndTamperingIsRejected() {
    JwtTokenService service = new JwtTokenService(SECRET, "farm-to-home-test", 10);

    String token = service.issue("google_123", "user@example.com");

    assertEquals("google_123", service.decode(token).getSubject());
    assertEquals("user@example.com", service.decode(token).getClaimAsString("email"));

    char replacement = token.charAt(token.length() - 1) == 'a' ? 'b' : 'a';
    String tampered = token.substring(0, token.length() - 1) + replacement;
    assertThrows(JwtException.class, () -> service.decode(tampered));
  }
}