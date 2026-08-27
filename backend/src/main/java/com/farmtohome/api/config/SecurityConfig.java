package com.farmtohome.api.config;

import com.farmtohome.api.auth.JwtTokenFilter;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
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
import org.springframework.web.filter.CorsFilter;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

  @Value("${app.cors-origins:https://flutter-frontend-production-e8d6.up.railway.app,https://*.railway.app,https://*.up.railway.app,http://localhost:*,*}")
  private String rawCorsOrigins;

  @Bean
  SecurityFilterChain securityFilterChain(
      HttpSecurity http,
      JwtTokenFilter jwtTokenFilter) throws Exception {
    return http
        .csrf(csrf -> csrf.disable())
        .cors(cors -> cors.configurationSource(corsConfigurationSource()))
        .sessionManagement(session ->
            session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .authorizeHttpRequests(auth -> auth
            .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
            .requestMatchers("/actuator/health", "/actuator/info", "/error").permitAll()
            .requestMatchers("/api/v1/auth/**").permitAll()
            .requestMatchers(HttpMethod.GET, "/api/v1/catalog/**", "/api/v1/products/**", "/api/v1/offers", "/api/v1/farmers/**", "/api/v1/delivery-slots").permitAll()
            .requestMatchers("/api/**").authenticated()
            .anyRequest().permitAll())
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
        .addFilterBefore(jwtTokenFilter, UsernamePasswordAuthenticationFilter.class)
        .build();
  }

  @Bean
  com.fasterxml.jackson.databind.ObjectMapper objectMapper() {
    return new com.fasterxml.jackson.databind.ObjectMapper().findAndRegisterModules();
  }

  @Bean
  UserDetailsService userDetailsService() {
    return username -> {
      throw new UsernameNotFoundException("Password login is not enabled on this API.");
    };
  }

  @Bean
  CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    
    if (rawCorsOrigins != null && !rawCorsOrigins.isBlank()) {
      Arrays.stream(rawCorsOrigins.split(","))
          .map(String::trim)
          .filter(s -> !s.isEmpty())
          .forEach(configuration::addAllowedOriginPattern);
    }

    // Explicit allowed origin patterns for Railway & local development
    configuration.addAllowedOriginPattern("https://flutter-frontend-production-e8d6.up.railway.app");
    configuration.addAllowedOriginPattern("https://*.up.railway.app");
    configuration.addAllowedOriginPattern("https://*.railway.app");
    configuration.addAllowedOriginPattern("http://localhost:*");
    configuration.addAllowedOriginPattern("http://127.0.0.1:*");
    configuration.addAllowedOriginPattern("*");
    
    configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD"));
    configuration.setAllowedHeaders(List.of("Authorization", "Content-Type", "Accept", "X-Requested-With", "Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers", "*"));
    configuration.setExposedHeaders(List.of(
        "Authorization", "Content-Type", "X-Total-Count", 
        "Access-Control-Allow-Origin", "Access-Control-Allow-Credentials"
    ));
    configuration.setAllowCredentials(true);
    configuration.setMaxAge(3600L);

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
  }
}
