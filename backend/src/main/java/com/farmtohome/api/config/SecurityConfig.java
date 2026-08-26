package com.farmtohome.api.config;

import com.farmtohome.api.auth.FirebaseTokenFilter;
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

  @Bean
  SecurityFilterChain securityFilterChain(
      HttpSecurity http,
      FirebaseTokenFilter firebaseTokenFilter) throws Exception {
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
        .addFilterBefore(firebaseTokenFilter, UsernamePasswordAuthenticationFilter.class)
        .build();
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
    // Allow origins using patterns (compatible with allowCredentials = true)
    configuration.addAllowedOriginPattern("*");
    configuration.addAllowedOriginPattern("https://*.railway.app");
    configuration.addAllowedOriginPattern("https://*.up.railway.app");
    configuration.addAllowedOriginPattern("http://localhost:*");
    configuration.addAllowedOriginPattern("http://127.0.0.1:*");
    
    configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD"));
    configuration.setAllowedHeaders(List.of("*"));
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

  @Bean
  public FilterRegistrationBean<CorsFilter> corsFilterRegistrationBean() {
    FilterRegistrationBean<CorsFilter> bean = new FilterRegistrationBean<>(new CorsFilter(corsConfigurationSource()));
    bean.setOrder(Ordered.HIGHEST_PRECEDENCE);
    return bean;
  }
}
