package com.farmtohome.api.order;

import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface OrderRepository extends JpaRepository<OrderEntity, UUID> {
  List<OrderEntity> findByOwnerUidOrderByCreatedAtDesc(String ownerUid);
  Optional<OrderEntity> findByIdAndOwnerUid(UUID id, String ownerUid);

  @Lock(LockModeType.PESSIMISTIC_WRITE)
  @Query("select o from OrderEntity o where o.id = :id and o.ownerUid = :uid")
  Optional<OrderEntity> findOwnedForUpdate(@Param("id") UUID id, @Param("uid") String uid);
}
