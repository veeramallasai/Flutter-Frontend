package com.farmtohome.api.cart;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CartItemRepository extends JpaRepository<CartItemEntity, Long> {
  List<CartItemEntity> findByOwnerUidOrderByUpdatedAtDesc(String ownerUid);
  Optional<CartItemEntity> findByOwnerUidAndItemKey(String ownerUid, String itemKey);
  void deleteByOwnerUidAndItemKey(String ownerUid, String itemKey);
  void deleteByOwnerUid(String ownerUid);
}
