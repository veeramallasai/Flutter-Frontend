package com.farmtohome.api.common;

import java.util.Map;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {
  private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

  @ExceptionHandler(ApiException.class)
  ResponseEntity<Map<String, Object>> api(ApiException error) {
    return ResponseEntity.status(error.status()).body(Map.of(
        "success", false,
        "message", error.getMessage(),
        "code", error.status().name()));
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  ResponseEntity<Map<String, Object>> validation(MethodArgumentNotValidException error) {
    String message = error.getBindingResult().getFieldErrors().stream()
        .map(value -> value.getField() + ": " + value.getDefaultMessage())
        .collect(Collectors.joining(", "));
    return ResponseEntity.badRequest().body(Map.of(
        "success", false, "message", message, "code", "VALIDATION_ERROR"));
  }

  @ExceptionHandler(AccessDeniedException.class)
  ResponseEntity<Map<String, Object>> denied(AccessDeniedException error) {
    return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of(
        "success", false, "message", "Access denied.", "code", "FORBIDDEN"));
  }

  @ExceptionHandler(org.springframework.dao.DataIntegrityViolationException.class)
  ResponseEntity<Map<String, Object>> dataIntegrity(org.springframework.dao.DataIntegrityViolationException error) {
    log.error("Data integrity violation", error);
    return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
        "success", false,
        "message", "An account already exists with this email address or details.",
        "code", "CONFLICT"));
  }

  @ExceptionHandler(Exception.class)
  ResponseEntity<Map<String, Object>> unexpected(Exception error) {
    log.error("Unhandled API exception: {}", error.getMessage(), error);
    String details = error.getMessage() != null && !error.getMessage().isBlank()
        ? error.getMessage()
        : error.getClass().getSimpleName();
    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
        "success", false,
        "message", "Server error: " + details,
        "code", "INTERNAL_ERROR"));
  }
}
