package com.farmtohome.api.user;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppUserRepository extends JpaRepository<AppUserEntity, String> {
  Optional<AppUserEntity> findByEmail(String email);
}

