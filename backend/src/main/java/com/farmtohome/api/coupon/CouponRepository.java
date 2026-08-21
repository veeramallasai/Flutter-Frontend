package com.farmtohome.api.coupon;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CouponRepository extends JpaRepository<CouponEntity, String> {
  Optional<CouponEntity> findByCodeIgnoreCaseAndActiveTrue(String code);
}
