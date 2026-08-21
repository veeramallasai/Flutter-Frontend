package com.farmtohome.api.address;

import com.farmtohome.api.common.ApiException;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AddressService {
  private static final List<String> TYPES = List.of("Home", "Work", "Other");

  private final AddressRepository addresses;

  public AddressService(AddressRepository addresses) {
    this.addresses = addresses;
  }

  @Transactional(readOnly = true)
  public List<AddressDtos.Address> list(String uid) {
    return addresses.findByOwnerUidOrderByDefaultAddressDescCreatedAtDesc(uid).stream()
        .map(this::view)
        .toList();
  }

  @Transactional(readOnly = true)
  public AddressDtos.Address get(String uid, UUID id) {
    return view(requireOwned(uid, id));
  }

  @Transactional
  public AddressDtos.Address create(String uid, AddressDtos.SaveRequest request) {
    boolean firstAddress = addresses.findByOwnerUidOrderByDefaultAddressDescCreatedAtDesc(uid)
        .isEmpty();
    AddressEntity address = new AddressEntity(UUID.randomUUID(), uid);
    apply(address, request);
    if (request.isDefault() || firstAddress) {
      clearDefaults(uid);
      address.setDefaultAddress(true);
    }
    return view(addresses.save(address));
  }

  @Transactional
  public AddressDtos.Address update(
      String uid,
      UUID id,
      AddressDtos.SaveRequest request) {
    AddressEntity address = requireOwned(uid, id);
    boolean wasDefault = address.isDefaultAddress();
    apply(address, request);
    if (request.isDefault()) {
      clearDefaults(uid);
      address.setDefaultAddress(true);
    } else if (wasDefault) {
      address.setDefaultAddress(true);
    }
    return view(addresses.save(address));
  }

  @Transactional
  public AddressDtos.Address makeDefault(String uid, UUID id) {
    requireOwned(uid, id);
    clearDefaults(uid);
    AddressEntity address = requireOwned(uid, id);
    address.setDefaultAddress(true);
    return view(addresses.save(address));
  }

  @Transactional
  public void delete(String uid, UUID id) {
    AddressEntity address = requireOwned(uid, id);
    boolean wasDefault = address.isDefaultAddress();
    addresses.delete(address);
    addresses.flush();
    if (wasDefault) {
      List<AddressEntity> remaining =
          addresses.findByOwnerUidOrderByDefaultAddressDescCreatedAtDesc(uid);
      if (!remaining.isEmpty()) {
        AddressEntity replacement = remaining.get(0);
        replacement.setDefaultAddress(true);
        addresses.save(replacement);
      }
    }
  }

  @Transactional(readOnly = true)
  public Map<String, Object> snapshot(String uid, String rawId) {
    UUID id;
    try {
      id = UUID.fromString(rawId == null ? "" : rawId.trim());
    } catch (IllegalArgumentException error) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Select a valid delivery address.");
    }
    AddressDtos.Address value = get(uid, id);
    Map<String, Object> snapshot = new LinkedHashMap<>();
    snapshot.put("id", value.id());
    snapshot.put("userId", value.userId());
    snapshot.put("fullName", value.fullName());
    snapshot.put("phone", value.phone());
    snapshot.put("addressLine1", value.addressLine1());
    snapshot.put("addressLine2", value.addressLine2());
    snapshot.put("city", value.city());
    snapshot.put("state", value.state());
    snapshot.put("postalCode", value.postalCode());
    snapshot.put("landmark", value.landmark());
    snapshot.put("type", value.type());
    snapshot.put("latitude", value.latitude());
    snapshot.put("longitude", value.longitude());
    return snapshot;
  }

  private AddressEntity requireOwned(String uid, UUID id) {
    return addresses.findByIdAndOwnerUid(id, uid)
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Address not found."));
  }

  private void clearDefaults(String uid) {
    for (AddressEntity value :
        addresses.findByOwnerUidOrderByDefaultAddressDescCreatedAtDesc(uid)) {
      if (value.isDefaultAddress()) {
        value.setDefaultAddress(false);
        addresses.save(value);
      }
    }
    addresses.flush();
  }

  private void apply(AddressEntity address, AddressDtos.SaveRequest request) {
    String type = text(request.type());
    if (!TYPES.contains(type)) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Address type must be Home, Work or Other.");
    }
    address.update(
        text(request.fullName()),
        text(request.phone()).replace(" ", ""),
        text(request.addressLine1()),
        text(request.addressLine2()),
        text(request.city()),
        text(request.state()),
        text(request.postalCode()),
        text(request.landmark()),
        type,
        request.latitude() == null ? BigDecimal.ZERO : request.latitude(),
        request.longitude() == null ? BigDecimal.ZERO : request.longitude());
  }

  private AddressDtos.Address view(AddressEntity value) {
    return new AddressDtos.Address(
        value.getId().toString(),
        value.getOwnerUid(),
        value.getFullName(),
        value.getPhone(),
        value.getAddressLine1(),
        value.getAddressLine2(),
        value.getCity(),
        value.getState(),
        value.getPostalCode(),
        value.getLandmark(),
        value.getAddressType(),
        value.isDefaultAddress(),
        value.getLatitude(),
        value.getLongitude(),
        value.getCreatedAt(),
        value.getUpdatedAt());
  }

  private static String text(String value) {
    return value == null ? "" : value.trim();
  }
}
