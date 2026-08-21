package com.farmtohome.api.product;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProductRepository extends JpaRepository<ProductEntity, String> {
  List<ProductEntity> findByActiveTrueOrderByCreatedAtDesc();
  List<ProductEntity> findByActiveTrueAndCategoryIgnoreCaseOrderByCreatedAtDesc(String category);

  @Lock(LockModeType.PESSIMISTIC_WRITE)
  @Query("select p from ProductEntity p where p.id = :id")
  ProductEntity findForUpdate(@Param("id") String id);
}
