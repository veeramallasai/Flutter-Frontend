package com.farmtohome.api.auth;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.stereotype.Service;
import com.nimbusds.jose.jwk.source.ImmutableSecret;
import com.nimbusds.jose.proc.SecurityContext;

@Service
public class JwtTokenService {
  private final JwtEncoder encoder;
  private final JwtDecoder decoder;
  private final String issuer;
  private final long expiryMinutes;

  public JwtTokenService(
      @Value("${app.jwt.secret}") String secret,
      @Value("${app.jwt.issuer}") String issuer,
      @Value("${app.jwt.expiry-minutes}") long expiryMinutes) {
    if (secret == null || secret.getBytes(StandardCharsets.UTF_8).length < 32) {
      throw new IllegalStateException("JWT_SECRET must contain at least 32 bytes.");
    }
    SecretKey key = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
    this.encoder = new NimbusJwtEncoder(new ImmutableSecret<SecurityContext>(key));
    NimbusJwtDecoder jwtDecoder = NimbusJwtDecoder.withSecretKey(key)
        .macAlgorithm(MacAlgorithm.HS256)
        .build();
    jwtDecoder.setJwtValidator(JwtValidators.createDefaultWithIssuer(issuer));
    this.decoder = jwtDecoder;
    this.issuer = issuer;
    this.expiryMinutes = expiryMinutes;
  }

  public String issue(String userId, String email) {
    Instant now = Instant.now();
    JwtClaimsSet claims = JwtClaimsSet.builder()
        .issuer(issuer)
        .issuedAt(now)
        .expiresAt(now.plus(expiryMinutes, ChronoUnit.MINUTES))
        .subject(userId)
        .claim("email", email)
        .claim("email_verified", true)
        .build();
    JwsHeader header = JwsHeader.with(MacAlgorithm.HS256).build();
    return encoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
  }

  public Jwt decode(String token) {
    return decoder.decode(token);
  }
}