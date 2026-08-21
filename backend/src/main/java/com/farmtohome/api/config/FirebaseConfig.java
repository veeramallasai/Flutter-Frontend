package com.farmtohome.api.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import java.io.IOException;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FirebaseConfig {
  @Bean
  @ConditionalOnMissingBean(ObjectMapper.class)
  ObjectMapper legacyObjectMapper() {
    return new ObjectMapper().findAndRegisterModules();
  }

  @Bean
  FirebaseApp firebaseApp(
      @Value("${app.firebase-project-id}") String projectId) throws IOException {
    if (!FirebaseApp.getApps().isEmpty()) {
      return FirebaseApp.getInstance();
    }
    FirebaseOptions options = FirebaseOptions.builder()
        .setCredentials(GoogleCredentials.getApplicationDefault())
        .setProjectId(projectId)
        .build();
    return FirebaseApp.initializeApp(options);
  }
}
