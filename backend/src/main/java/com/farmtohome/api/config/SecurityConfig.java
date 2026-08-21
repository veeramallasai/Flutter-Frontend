package com.farmtohome.api.config;

import com.farmtohome.api.auth.FirebaseTokenFilter;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {
  @Bean
  SecurityFilterChain securityFilterChain(
      HttpSecurity http,
      FirebaseTokenFilter firebaseTokenFilter) throws Exception {
    return http
        .csrf(csrf -> csrf.disable())
        .cors(cors -> {})
        .sessionManagement(session ->
            session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/actuator/health", "/actuator/info").permitAll()
            .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
            .requestMatchers("/api/**").authenticated()
            .anyRequest().denyAll())
        .exceptionHandling(exceptions -> exceptions
            .authenticationEntryPoint((request, response, error) -> {
              response.setStatus(401);
              response.setContentType("application/json");
              response.getWriter().write(
                  "{\"success\":false,\"message\":\"Authentication required.\","
                      + "\"code\":\"UNAUTHORIZED\"}");
            })
            .accessDeniedHandler((request, response, error) -> {
              response.setStatus(403);
              response.setContentType("application/json");
              response.getWriter().write(
                  "{\"success\":false,\"message\":\"Access denied.\","
                      + "\"code\":\"FORBIDDEN\"}");
            }))
        .addFilterBefore(firebaseTokenFilter, UsernamePasswordAuthenticationFilter.class)
        .build();
  }

  @Bean
  UserDetailsService userDetailsService() {
    // Authentication is handled exclusively by verified Firebase ID tokens.
    // Declaring this bean also disables Spring's generated development password.
    return username -> {
      throw new UsernameNotFoundException("Password login is not enabled on this API.");
    };
  }

  @Bean
  CorsConfigurationSource corsConfigurationSource(
      @Value("${app.cors-origins}") String origins) {
    CorsConfiguration configuration = new CorsConfiguration();
    configuration.setAllowedOriginPatterns(Arrays.stream(origins.split(","))
        .map(String::trim)
        .filter(value -> !value.isBlank())
        .toList());
    configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
    configuration.setAllowedHeaders(List.of("Authorization", "Content-Type", "Accept"));
    configuration.setExposedHeaders(List.of("Location"));
    configuration.setAllowCredentials(true);
    configuration.setMaxAge(3600L);
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
  }
}
