package com.farmtohome.api.address;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AddressRepository extends JpaRepository<AddressEntity, UUID> {
  List<AddressEntity> findByOwnerUidOrderByDefaultAddressDescCreatedAtDesc(String ownerUid);
  Optional<AddressEntity> findByIdAndOwnerUid(UUID id, String ownerUid);
}
