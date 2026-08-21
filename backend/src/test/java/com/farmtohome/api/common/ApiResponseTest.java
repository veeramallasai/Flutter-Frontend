package com.farmtohome.api.common;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Map;
import org.junit.jupiter.api.Test;

class ApiResponseTest {
  @Test
  void successEnvelopeKeepsDataAndMessage() {
    ApiResponse<Map<String, Object>> response =
        ApiResponse.ok(Map.of("status", "ready"), "Verified");

    assertThat(response.success()).isTrue();
    assertThat(response.data()).containsEntry("status", "ready");
    assertThat(response.message()).isEqualTo("Verified");
  }
}
