package com.farmtohome.api.address;

import com.farmtohome.api.common.ApiResponse;
import jakarta.validation.Valid;
import java.security.Principal;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/addresses")
public class AddressController {
  private final AddressService addresses;

  public AddressController(AddressService addresses) {
    this.addresses = addresses;
  }

  @GetMapping
  ApiResponse<List<AddressDtos.Address>> list(Principal principal) {
    return ApiResponse.ok(addresses.list(principal.getName()));
  }

  @PostMapping
  ApiResponse<AddressDtos.Address> create(
      Principal principal,
      @Valid @RequestBody AddressDtos.SaveRequest request) {
    return ApiResponse.ok(
        addresses.create(principal.getName(), request),
        "Address saved.");
  }

  @PutMapping("/{id}")
  ApiResponse<AddressDtos.Address> update(
      Principal principal,
      @PathVariable UUID id,
      @Valid @RequestBody AddressDtos.SaveRequest request) {
    return ApiResponse.ok(
        addresses.update(principal.getName(), id, request),
        "Address updated.");
  }

  @PatchMapping("/{id}/default")
  ApiResponse<AddressDtos.Address> makeDefault(
      Principal principal,
      @PathVariable UUID id) {
    return ApiResponse.ok(
        addresses.makeDefault(principal.getName(), id),
        "Default address updated.");
  }

  @DeleteMapping("/{id}")
  ApiResponse<Map<String, String>> delete(
      Principal principal,
      @PathVariable UUID id) {
    addresses.delete(principal.getName(), id);
    return ApiResponse.ok(Map.of("id", id.toString()), "Address deleted.");
  }
}
