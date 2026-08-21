package com.farmtohome.api.order;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderItemRepository extends JpaRepository<OrderItemEntity, Long> {
  List<OrderItemEntity> findByOrderIdOrderById(UUID orderId);
}
