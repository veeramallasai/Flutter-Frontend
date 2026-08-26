package com.farmtohome.api.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class FirebaseTokenFilter extends OncePerRequestFilter {
  private final FirebaseAuth firebaseAuth;
  private final ObjectMapper objectMapper;

  public FirebaseTokenFilter(ObjectMapper objectMapper, FirebaseApp firebaseApp) {
    this.firebaseAuth = FirebaseAuth.getInstance(firebaseApp);
    this.objectMapper = objectMapper;
  }

  @Override
  protected void doFilterInternal(
      HttpServletRequest request,
      HttpServletResponse response,
      FilterChain filterChain) throws ServletException, IOException {
    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
      filterChain.doFilter(request, response);
      return;
    }

    String authorization = request.getHeader("Authorization");
    if (authorization == null || !authorization.startsWith("Bearer ")) {
      filterChain.doFilter(request, response);
      return;
    }

    try {
      FirebaseToken token = firebaseAuth.verifyIdToken(authorization.substring(7).trim());
      List<SimpleGrantedAuthority> authorities = new ArrayList<>();
      authorities.add(new SimpleGrantedAuthority("ROLE_USER"));
      if (Boolean.TRUE.equals(token.getClaims().get("admin"))) {
        authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
      }
      var authentication = new UsernamePasswordAuthenticationToken(
          token.getUid(), token, authorities);
      SecurityContextHolder.getContext().setAuthentication(authentication);
      filterChain.doFilter(request, response);
    } catch (FirebaseAuthException | IllegalArgumentException error) {
      SecurityContextHolder.clearContext();
      response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
      response.setContentType(MediaType.APPLICATION_JSON_VALUE);
      objectMapper.writeValue(response.getOutputStream(), Map.of(
          "success", false,
          "message", "Login session expired. Please sign in again.",
          "code", "INVALID_TOKEN"));
    }
  }
}
