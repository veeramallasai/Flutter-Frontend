package com.farmtohome.api.platform;

import com.farmtohome.api.common.ApiResponse;
import jakarta.validation.Valid;
import java.security.Principal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class PlatformController {
  private final PlatformService platform;

  public PlatformController(PlatformService platform) {
    this.platform = platform;
  }

  @GetMapping("/catalog/categories")
  ApiResponse<List<Map<String, Object>>> categories() {
    return ApiResponse.ok(platform.categories());
  }

  @GetMapping("/catalog/banners")
  ApiResponse<List<Map<String, Object>>> banners() {
    return ApiResponse.ok(platform.banners());
  }

  @GetMapping("/offers")
  ApiResponse<List<Map<String, Object>>> offers() {
    return ApiResponse.ok(platform.offers());
  }

  @GetMapping("/farmers")
  ApiResponse<List<Map<String, Object>>> farmers(
      @RequestParam(defaultValue = "50") int limit) {
    return ApiResponse.ok(platform.farmers(limit));
  }

  @GetMapping("/farmers/{id}")
  ApiResponse<Map<String, Object>> farmer(@PathVariable String id) {
    return ApiResponse.ok(platform.farmer(id));
  }

  @GetMapping("/delivery-slots")
  ApiResponse<List<Map<String, Object>>> deliverySlots(
      @RequestParam(defaultValue = "standard") String method,
      @RequestParam(required = false)
      @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
    return ApiResponse.ok(platform.deliverySlots(method, date));
  }

  @PostMapping("/delivery-slots/{id}/reserve")
  ApiResponse<Map<String, Object>> reserveDeliverySlot(@PathVariable String id) {
    return ApiResponse.ok(platform.reserveDeliverySlot(id), "Delivery slot reserved.");
  }

  @DeleteMapping("/delivery-slots/{id}/reserve")
  ApiResponse<Map<String, Object>> releaseDeliverySlot(@PathVariable String id) {
    return ApiResponse.ok(platform.releaseDeliverySlot(id), "Delivery slot released.");
  }

  @GetMapping("/favorites")
  ApiResponse<List<Map<String, Object>>> favorites(Principal principal) {
    return ApiResponse.ok(platform.favorites(principal.getName()));
  }

  @PostMapping("/favorites/{productId}")
  ApiResponse<Map<String, Object>> addFavorite(
      Principal principal,
      @PathVariable String productId) {
    return ApiResponse.ok(
        platform.addFavorite(principal.getName(), productId),
        "Added to favorites.");
  }

  @DeleteMapping("/favorites/{productId}")
  ApiResponse<Map<String, Object>> removeFavorite(
      Principal principal,
      @PathVariable String productId) {
    return ApiResponse.ok(
        platform.removeFavorite(principal.getName(), productId),
        "Removed from favorites.");
  }

  @GetMapping("/products/{productId}/reviews")
  ApiResponse<List<Map<String, Object>>> reviews(@PathVariable String productId) {
    return ApiResponse.ok(platform.reviews(productId));
  }

  @PostMapping("/products/{productId}/reviews")
  ApiResponse<Map<String, Object>> saveReview(
      Principal principal,
      @PathVariable String productId,
      @Valid @RequestBody PlatformDtos.ReviewRequest request) {
    return ApiResponse.ok(
        platform.saveReview(principal.getName(), productId, request),
        "Review saved.");
  }

  @DeleteMapping("/reviews/{id}")
  ApiResponse<Map<String, Object>> deleteReview(
      Principal principal,
      @PathVariable UUID id) {
    return ApiResponse.ok(
        platform.deleteReview(principal.getName(), id),
        "Review deleted.");
  }

  @GetMapping("/orders/{orderId}/delivery-partner")
  ApiResponse<Map<String, Object>> deliveryPartnerForOrder(
      Principal principal,
      @PathVariable UUID orderId) {
    return ApiResponse.ok(
        platform.deliveryPartnerForOrder(principal.getName(), orderId));
  }

  @GetMapping("/orders/{orderId}/delivery-partner/review")
  ApiResponse<Map<String, Object>> deliveryPartnerReview(
      Principal principal,
      @PathVariable UUID orderId) {
    return ApiResponse.ok(
        platform.deliveryPartnerReview(principal.getName(), orderId));
  }

  @PostMapping("/orders/{orderId}/delivery-partner/review")
  ApiResponse<Map<String, Object>> saveDeliveryPartnerReview(
      Principal principal,
      @PathVariable UUID orderId,
      @Valid @RequestBody PlatformDtos.DeliveryPartnerReviewRequest request) {
    return ApiResponse.ok(
        platform.saveDeliveryPartnerReview(principal.getName(), orderId, request),
        "Delivery partner review saved.");
  }

  @DeleteMapping("/orders/{orderId}/delivery-partner/review")
  ApiResponse<Map<String, Object>> deleteDeliveryPartnerReview(
      Principal principal,
      @PathVariable UUID orderId) {
    return ApiResponse.ok(
        platform.deleteDeliveryPartnerReview(principal.getName(), orderId),
        "Delivery partner review deleted.");
  }

  @GetMapping("/notifications")
  ApiResponse<List<Map<String, Object>>> notifications(
      Principal principal,
      @RequestParam(defaultValue = "100") int limit) {
    return ApiResponse.ok(platform.notifications(principal.getName(), limit));
  }

  @PatchMapping("/notifications/{id}/read")
  ApiResponse<Map<String, Object>> readNotification(
      Principal principal,
      @PathVariable UUID id) {
    return ApiResponse.ok(
        platform.readNotification(principal.getName(), id),
        "Notification marked as read.");
  }

  @PatchMapping("/notifications/read-all")
  ApiResponse<Map<String, Object>> readAllNotifications(Principal principal) {
    return ApiResponse.ok(
        platform.readAllNotifications(principal.getName()),
        "All notifications marked as read.");
  }

  @DeleteMapping("/notifications/{id}")
  ApiResponse<Map<String, Object>> deleteNotification(
      Principal principal,
      @PathVariable UUID id) {
    return ApiResponse.ok(
        platform.deleteNotification(principal.getName(), id),
        "Notification deleted.");
  }

  @GetMapping("/notification-preferences")
  ApiResponse<Map<String, Object>> notificationPreferences(Principal principal) {
    return ApiResponse.ok(platform.notificationPreferences(principal.getName()));
  }

  @PutMapping("/notification-preferences")
  ApiResponse<Map<String, Object>> updateNotificationPreferences(
      Principal principal,
      @Valid @RequestBody PlatformDtos.NotificationPreferencesRequest request) {
    return ApiResponse.ok(
        platform.updateNotificationPreferences(principal.getName(), request),
        "Notification preferences updated.");
  }

  @GetMapping("/support-tickets")
  ApiResponse<List<Map<String, Object>>> supportTickets(Principal principal) {
    return ApiResponse.ok(platform.supportTickets(principal.getName()));
  }

  @PostMapping("/support-tickets")
  ApiResponse<Map<String, Object>> createSupportTicket(
      Principal principal,
      @Valid @RequestBody PlatformDtos.SupportRequest request) {
    return ApiResponse.ok(
        platform.createSupportTicket(principal.getName(), request),
        "Support request created.");
  }

  @PatchMapping("/support-tickets/{id}/close")
  ApiResponse<Map<String, Object>> closeSupportTicket(
      Principal principal,
      @PathVariable UUID id) {
    return ApiResponse.ok(
        platform.closeSupportTicket(principal.getName(), id),
        "Support request closed.");
  }

  @PostMapping("/devices")
  ApiResponse<Map<String, Object>> registerDevice(
      Principal principal,
      @Valid @RequestBody PlatformDtos.DeviceRequest request) {
    return ApiResponse.ok(
        platform.registerDevice(principal.getName(), request),
        "Device registered.");
  }

  @DeleteMapping("/devices")
  ApiResponse<Map<String, Object>> removeDevice(
      Principal principal,
      @RequestParam String token) {
    return ApiResponse.ok(
        platform.removeDevice(principal.getName(), token),
        "Device removed.");
  }
}
