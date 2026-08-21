package com.farmtohome.api.platform;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.farmtohome.api.common.ApiException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PlatformService {
  private static final Set<String> DELIVERY_METHODS =
      Set.of("standard", "express", "scheduled", "pickup");
  private static final Set<String> SUPPORT_PRIORITIES =
      Set.of("low", "normal", "high", "urgent");

  private final JdbcTemplate jdbc;
  private final ObjectMapper json;

  public PlatformService(JdbcTemplate jdbc, ObjectMapper json) {
    this.jdbc = jdbc;
    this.json = json;
  }

  @Transactional(readOnly = true)
  public List<Map<String, Object>> categories() {
    return jdbc.query("""
        SELECT c.id, c.name, c.description, c.image_url, c.icon_name,
               c.sort_order, c.active, c.created_at, c.updated_at,
               (SELECT count(*) FROM products p
                WHERE p.active = true AND lower(p.category) = lower(c.id)) AS product_count
        FROM categories c
        WHERE c.active = true
        ORDER BY c.sort_order, c.name
        """, (rs, row) -> category(rs));
  }

  @Transactional(readOnly = true)
  public List<Map<String, Object>> banners() {
    return jdbc.query("""
        SELECT id, title, subtitle, image_url, action_label, route, priority,
               active, starts_at, ends_at
        FROM banners
        WHERE active = true
          AND (starts_at IS NULL OR starts_at <= now())
          AND (ends_at IS NULL OR ends_at >= now())
        ORDER BY priority, created_at DESC
        """, (rs, row) -> banner(rs));
  }

  @Transactional(readOnly = true)
  public List<Map<String, Object>> offers() {
    return jdbc.query("""
        SELECT id, title, description, code, discount_type, discount_value,
               minimum_order, maximum_discount, image_url, active,
               starts_at, ends_at
        FROM offers
        WHERE active = true
          AND (starts_at IS NULL OR starts_at <= now())
          AND (ends_at IS NULL OR ends_at >= now())
        ORDER BY created_at DESC
        """, (rs, row) -> offer(rs));
  }

  @Transactional(readOnly = true)
  public List<Map<String, Object>> farmers(int rawLimit) {
    int limit = Math.max(1, Math.min(rawLimit, 100));
    return jdbc.query("""
        SELECT id, name, farm_name, location, image_url, rating, review_count,
               verified, experience_years, speciality
        FROM farmers
        WHERE active = true
        ORDER BY verified DESC, rating DESC, name
        LIMIT ?
        """, (rs, row) -> farmer(rs), limit);
  }

  @Transactional(readOnly = true)
  public Map<String, Object> farmer(String id) {
    try {
      return jdbc.queryForObject("""
          SELECT id, name, farm_name, location, image_url, rating, review_count,
                 verified, experience_years, speciality
          FROM farmers
          WHERE id = ? AND active = true
          """, (rs, row) -> farmer(rs), clean(id));
    } catch (EmptyResultDataAccessException error) {
      throw new ApiException(HttpStatus.NOT_FOUND, "Farmer not found.");
    }
  }

  @Transactional(readOnly = true)
  public List<Map<String, Object>> deliverySlots(String rawMethod, LocalDate date) {
    String method = normalizeMethod(rawMethod);
    return jdbc.query("""
        SELECT id, method, label, start_time, end_time, fee, available,
               capacity, booked_count, slot_date
        FROM delivery_slots
        WHERE method = ? AND available = true
          AND (capacity = 0 OR booked_count < capacity)
          AND (slot_date IS NULL OR slot_date = ?)
        ORDER BY slot_date NULLS FIRST, start_time
        """, (rs, row) -> deliverySlot(rs), method, date == null ? null : Date.valueOf(date));
  }

  @Transactional
  public Map<String, Object> reserveDeliverySlot(String rawId) {
    String id = clean(rawId);
    int updated = jdbc.update("""
        UPDATE delivery_slots
        SET booked_count = booked_count + 1, updated_at = now()
        WHERE id = ? AND available = true
          AND (capacity = 0 OR booked_count < capacity)
        """, id);
    if (updated == 0) {
      throw new ApiException(HttpStatus.CONFLICT, "Delivery slot is no longer available.");
    }
    return deliverySlotById(id);
  }

  @Transactional
  public Map<String, Object> releaseDeliverySlot(String rawId) {
    String id = clean(rawId);
    int updated = jdbc.update("""
        UPDATE delivery_slots
        SET booked_count = GREATEST(booked_count - 1, 0), updated_at = now()
        WHERE id = ?
        """, id);
    if (updated == 0) {
      throw new ApiException(HttpStatus.NOT_FOUND, "Delivery slot not found.");
    }
    return deliverySlotById(id);
  }

  @Transactional(readOnly = true)
  public List<Map<String, Object>> favorites(String uid) {
    return jdbc.query("""
        SELECT p.*
        FROM favorites f
        JOIN products p ON p.id = f.product_id
        WHERE f.owner_uid = ? AND p.active = true
        ORDER BY f.created_at DESC
        """, (rs, row) -> product(rs), uid);
  }

  @Transactional
  public Map<String, Object> addFavorite(String uid, String rawProductId) {
    String productId = requireProduct(rawProductId);
    jdbc.update("""
        INSERT INTO favorites(owner_uid, product_id)
        VALUES (?, ?)
        ON CONFLICT (owner_uid, product_id) DO NOTHING
        """, uid, productId);
    return Map.of("productId", productId, "isFavorite", true);
  }

  @Transactional
  public Map<String, Object> removeFavorite(String uid, String rawProductId) {
    String productId = clean(rawProductId);
    jdbc.update("DELETE FROM favorites WHERE owner_uid = ? AND product_id = ?", uid, productId);
    return Map.of("productId", productId, "isFavorite", false);
  }

  @Transactional(readOnly = true)
  public List<Map<String, Object>> reviews(String rawProductId) {
    String productId = requireProduct(rawProductId);
    return jdbc.query("""
        SELECT id, product_id, owner_uid, user_name, rating, comment,
               image_urls, verified_purchase, created_at, updated_at
        FROM reviews
        WHERE product_id = ?
        ORDER BY created_at DESC
        """, (rs, row) -> review(rs), productId);
  }

  @Transactional
  public Map<String, Object> saveReview(
      String uid,
      String rawProductId,
      PlatformDtos.ReviewRequest request) {
    String productId = requireProduct(rawProductId);
    boolean verifiedPurchase = Boolean.TRUE.equals(jdbc.queryForObject("""
        SELECT EXISTS(
          SELECT 1 FROM order_items oi
          JOIN orders o ON o.id = oi.order_id
          WHERE o.owner_uid = ? AND oi.product_id = ? AND o.status = 'delivered'
        )
        """, Boolean.class, uid, productId));
    if (!verifiedPurchase) {
      throw new ApiException(
          HttpStatus.BAD_REQUEST,
          "Product reviews are available only for delivered purchases.");
    }
    String images = encode(request.images() == null ? List.of() : request.images());
    UUID id = UUID.randomUUID();
    Map<String, Object> saved = jdbc.queryForObject("""
        INSERT INTO reviews(
          id, product_id, owner_uid, user_name, rating, comment,
          image_urls, verified_purchase)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT (owner_uid, product_id) DO UPDATE SET
          user_name = EXCLUDED.user_name,
          rating = EXCLUDED.rating,
          comment = EXCLUDED.comment,
          image_urls = EXCLUDED.image_urls,
          verified_purchase = EXCLUDED.verified_purchase,
          updated_at = now()
        RETURNING id, product_id, owner_uid, user_name, rating, comment,
                  image_urls, verified_purchase, created_at, updated_at
        """, (rs, row) -> review(rs), id, productId, uid,
        clean(request.userName()), request.rating(), clean(request.comment()),
        images, verifiedPurchase);
    refreshProductRating(productId);
    return saved;
  }

  @Transactional
  public Map<String, Object> deleteReview(String uid, UUID id) {
    String productId;
    try {
      productId = jdbc.queryForObject(
          "SELECT product_id FROM reviews WHERE id = ? AND owner_uid = ?",
          String.class, id, uid);
    } catch (EmptyResultDataAccessException error) {
      throw new ApiException(HttpStatus.NOT_FOUND, "Review not found.");
    }
    jdbc.update("DELETE FROM reviews WHERE id = ? AND owner_uid = ?", id, uid);
    refreshProductRating(productId);
    return Map.of("id", id.toString());
  }


  @Transactional(readOnly = true)
  public Map<String, Object> deliveryPartnerForOrder(String uid, UUID orderId) {
    try {
      return jdbc.queryForObject("""
          SELECT dp.id, dp.name, dp.phone, dp.photo_url, dp.vehicle_number,
                 dp.rating, dp.review_count, dp.is_active, o.status
          FROM orders o
          JOIN delivery_partners dp ON dp.id = o.delivery_partner_id
          WHERE o.id = ? AND o.owner_uid = ?
          """, (rs, row) -> {
        Map<String, Object> value = map();
        value.put("id", rs.getObject("id", UUID.class).toString());
        value.put("name", rs.getString("name"));
        value.put("phone", rs.getString("phone"));
        value.put("photoUrl", rs.getString("photo_url"));
        value.put("vehicleNumber", rs.getString("vehicle_number"));
        value.put("rating", rs.getBigDecimal("rating"));
        value.put("reviewCount", rs.getInt("review_count"));
        value.put("isActive", rs.getBoolean("is_active"));
        value.put("orderStatus", rs.getString("status"));
        return value;
      }, orderId, uid);
    } catch (EmptyResultDataAccessException error) {
      throw new ApiException(
          HttpStatus.NOT_FOUND,
          "Delivery partner is not assigned to this order.");
    }
  }

  @Transactional(readOnly = true)
  public Map<String, Object> deliveryPartnerReview(String uid, UUID orderId) {
    List<Map<String, Object>> values = jdbc.query("""
        SELECT id, order_id, customer_uid, delivery_partner_id, rating, comment,
               created_at, updated_at
        FROM delivery_partner_reviews
        WHERE order_id = ? AND customer_uid = ?
        """, (rs, row) -> deliveryPartnerReview(rs), orderId, uid);
    return values.isEmpty() ? Map.of() : values.get(0);
  }

  @Transactional
  public Map<String, Object> saveDeliveryPartnerReview(
      String uid,
      UUID orderId,
      PlatformDtos.DeliveryPartnerReviewRequest request) {
    UUID partnerId;
    try {
      partnerId = jdbc.queryForObject("""
          SELECT delivery_partner_id
          FROM orders
          WHERE id = ?
            AND owner_uid = ?
            AND status = 'delivered'
            AND delivery_partner_id IS NOT NULL
          """, UUID.class, orderId, uid);
    } catch (EmptyResultDataAccessException error) {
      throw new ApiException(
          HttpStatus.BAD_REQUEST,
          "Delivery partner review is available only after a delivered order with an assigned partner.");
    }

    UUID reviewId = UUID.randomUUID();
    Map<String, Object> saved = jdbc.queryForObject("""
        INSERT INTO delivery_partner_reviews(
          id, order_id, customer_uid, delivery_partner_id, rating, comment)
        VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT (order_id, customer_uid) DO UPDATE SET
          delivery_partner_id = EXCLUDED.delivery_partner_id,
          rating = EXCLUDED.rating,
          comment = EXCLUDED.comment,
          updated_at = now()
        RETURNING id, order_id, customer_uid, delivery_partner_id, rating,
                  comment, created_at, updated_at
        """, (rs, row) -> deliveryPartnerReview(rs),
        reviewId, orderId, uid, partnerId, request.rating(), clean(request.comment()));

    refreshDeliveryPartnerRating(partnerId);
    return saved;
  }

  @Transactional
  public Map<String, Object> deleteDeliveryPartnerReview(String uid, UUID orderId) {
    UUID partnerId;
    try {
      partnerId = jdbc.queryForObject("""
          SELECT delivery_partner_id
          FROM delivery_partner_reviews
          WHERE order_id = ? AND customer_uid = ?
          """, UUID.class, orderId, uid);
    } catch (EmptyResultDataAccessException error) {
      throw new ApiException(HttpStatus.NOT_FOUND, "Delivery partner review not found.");
    }

    jdbc.update("""
        DELETE FROM delivery_partner_reviews
        WHERE order_id = ? AND customer_uid = ?
        """, orderId, uid);
    refreshDeliveryPartnerRating(partnerId);
    return Map.of("orderId", orderId.toString());
  }

  @Transactional(readOnly = true)
  public List<Map<String, Object>> notifications(String uid, int rawLimit) {
    int limit = Math.max(1, Math.min(rawLimit, 200));
    return jdbc.query("""
        SELECT id, owner_uid, title, body, notification_type, image_url,
               route, data_json, is_read, created_at
        FROM notifications
        WHERE owner_uid = ?
        ORDER BY created_at DESC
        LIMIT ?
        """, (rs, row) -> notification(rs), uid, limit);
  }

  @Transactional
  public Map<String, Object> readNotification(String uid, UUID id) {
    int updated = jdbc.update(
        "UPDATE notifications SET is_read = true WHERE id = ? AND owner_uid = ?",
        id, uid);
    requireUpdated(updated, "Notification not found.");
    return Map.of("id", id.toString(), "isRead", true);
  }

  @Transactional
  public Map<String, Object> readAllNotifications(String uid) {
    int updated = jdbc.update(
        "UPDATE notifications SET is_read = true WHERE owner_uid = ? AND is_read = false",
        uid);
    return Map.of("updatedCount", updated);
  }

  @Transactional
  public Map<String, Object> deleteNotification(String uid, UUID id) {
    int updated = jdbc.update(
        "DELETE FROM notifications WHERE id = ? AND owner_uid = ?", id, uid);
    requireUpdated(updated, "Notification not found.");
    return Map.of("id", id.toString());
  }

  @Transactional(readOnly = true)
  public Map<String, Object> notificationPreferences(String uid) {
    List<Map<String, Object>> values = jdbc.query("""
        SELECT order_updates, offers, updated_at
        FROM notification_preferences
        WHERE owner_uid = ?
        """, (rs, row) -> notificationPreferences(rs), uid);
    if (values.isEmpty()) {
      return Map.of("orderUpdates", true, "offers", true);
    }
    return values.get(0);
  }

  @Transactional
  public Map<String, Object> updateNotificationPreferences(
      String uid,
      PlatformDtos.NotificationPreferencesRequest request) {
    return jdbc.queryForObject("""
        INSERT INTO notification_preferences(owner_uid, order_updates, offers)
        VALUES (?, ?, ?)
        ON CONFLICT (owner_uid) DO UPDATE SET
          order_updates = EXCLUDED.order_updates,
          offers = EXCLUDED.offers,
          updated_at = now()
        RETURNING order_updates, offers, updated_at
        """, (rs, row) -> notificationPreferences(rs), uid,
        request.orderUpdates(), request.offers());
  }

  @Transactional(readOnly = true)
  public List<Map<String, Object>> supportTickets(String uid) {
    return jdbc.query("""
        SELECT id, owner_uid, subject, message, category, status, priority,
               response, created_at, updated_at
        FROM support_tickets
        WHERE owner_uid = ?
        ORDER BY updated_at DESC
        """, (rs, row) -> supportTicket(rs), uid);
  }

  @Transactional
  public Map<String, Object> createSupportTicket(
      String uid,
      PlatformDtos.SupportRequest request) {
    String priority = lowerOr(request.priority(), "normal");
    if (!SUPPORT_PRIORITIES.contains(priority)) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Invalid support priority.");
    }
    UUID id = UUID.randomUUID();
    return jdbc.queryForObject("""
        INSERT INTO support_tickets(
          id, owner_uid, subject, message, category, priority)
        VALUES (?, ?, ?, ?, ?, ?)
        RETURNING id, owner_uid, subject, message, category, status, priority,
                  response, created_at, updated_at
        """, (rs, row) -> supportTicket(rs), id, uid, clean(request.subject()),
        clean(request.message()), lowerOr(request.category(), "general"), priority);
  }

  @Transactional
  public Map<String, Object> closeSupportTicket(String uid, UUID id) {
    int updated = jdbc.update("""
        UPDATE support_tickets
        SET status = 'closed', updated_at = now()
        WHERE id = ? AND owner_uid = ? AND status <> 'closed'
        """, id, uid);
    if (updated == 0) {
      try {
        return supportTicket(uid, id);
      } catch (ApiException error) {
        throw new ApiException(HttpStatus.NOT_FOUND, "Support request not found.");
      }
    }
    return supportTicket(uid, id);
  }

  @Transactional
  public Map<String, Object> registerDevice(
      String uid,
      PlatformDtos.DeviceRequest request) {
    String token = clean(request.token());
    jdbc.update("""
        INSERT INTO device_tokens(owner_uid, token, platform, device_name)
        VALUES (?, ?, ?, ?)
        ON CONFLICT (token) DO UPDATE SET
          owner_uid = EXCLUDED.owner_uid,
          platform = EXCLUDED.platform,
          device_name = EXCLUDED.device_name,
          active = true,
          last_seen_at = now()
        """, uid, token, lowerOr(request.platform(), "unknown"), clean(request.deviceName()));
    return Map.of("token", token, "active", true);
  }

  @Transactional
  public Map<String, Object> removeDevice(String uid, String rawToken) {
    String token = clean(rawToken);
    int updated = jdbc.update("""
        UPDATE device_tokens SET active = false, last_seen_at = now()
        WHERE token = ? AND owner_uid = ?
        """, token, uid);
    requireUpdated(updated, "Device token not found.");
    return Map.of("token", token, "active", false);
  }

  private Map<String, Object> deliverySlotById(String id) {
    try {
      return jdbc.queryForObject("""
          SELECT id, method, label, start_time, end_time, fee, available,
                 capacity, booked_count, slot_date
          FROM delivery_slots WHERE id = ?
          """, (rs, row) -> deliverySlot(rs), id);
    } catch (EmptyResultDataAccessException error) {
      throw new ApiException(HttpStatus.NOT_FOUND, "Delivery slot not found.");
    }
  }

  private Map<String, Object> supportTicket(String uid, UUID id) {
    try {
      return jdbc.queryForObject("""
          SELECT id, owner_uid, subject, message, category, status, priority,
                 response, created_at, updated_at
          FROM support_tickets WHERE id = ? AND owner_uid = ?
          """, (rs, row) -> supportTicket(rs), id, uid);
    } catch (EmptyResultDataAccessException error) {
      throw new ApiException(HttpStatus.NOT_FOUND, "Support request not found.");
    }
  }

  private String requireProduct(String rawProductId) {
    String productId = clean(rawProductId);
    Long count = jdbc.queryForObject(
        "SELECT count(*) FROM products WHERE id = ? AND active = true",
        Long.class, productId);
    if (count == null || count == 0L) {
      throw new ApiException(HttpStatus.NOT_FOUND, "Product not found.");
    }
    return productId;
  }

  private void refreshProductRating(String productId) {
    jdbc.update("""
        UPDATE products p SET
          rating = COALESCE((SELECT round(avg(r.rating), 1) FROM reviews r WHERE r.product_id = p.id), 0),
          review_count = (SELECT count(*) FROM reviews r WHERE r.product_id = p.id),
          updated_at = now()
        WHERE p.id = ?
        """, productId);
  }


  private void refreshDeliveryPartnerRating(UUID partnerId) {
    jdbc.update("""
        UPDATE delivery_partners dp SET
          rating = COALESCE(
            (SELECT round(avg(r.rating), 1)
             FROM delivery_partner_reviews r
             WHERE r.delivery_partner_id = dp.id), 0),
          review_count = (
            SELECT count(*)
            FROM delivery_partner_reviews r
            WHERE r.delivery_partner_id = dp.id),
          updated_at = now()
        WHERE dp.id = ?
        """, partnerId);
  }

  private String normalizeMethod(String rawMethod) {
    String method = lowerOr(rawMethod, "standard");
    if ("quick".equals(method)) method = "express";
    if (!DELIVERY_METHODS.contains(method)) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Invalid delivery method.");
    }
    return method;
  }

  private static void requireUpdated(int updated, String message) {
    if (updated == 0) throw new ApiException(HttpStatus.NOT_FOUND, message);
  }

  private Map<String, Object> category(ResultSet rs) throws SQLException {
    Map<String, Object> value = map();
    value.put("id", rs.getString("id"));
    value.put("name", rs.getString("name"));
    value.put("description", rs.getString("description"));
    value.put("imageUrl", rs.getString("image_url"));
    value.put("iconName", rs.getString("icon_name"));
    value.put("productCount", rs.getInt("product_count"));
    value.put("sortOrder", rs.getInt("sort_order"));
    value.put("isActive", rs.getBoolean("active"));
    value.put("createdAt", instant(rs, "created_at"));
    value.put("updatedAt", instant(rs, "updated_at"));
    return value;
  }

  private Map<String, Object> banner(ResultSet rs) throws SQLException {
    Map<String, Object> value = map();
    value.put("id", rs.getString("id"));
    value.put("title", rs.getString("title"));
    value.put("subtitle", rs.getString("subtitle"));
    value.put("imageUrl", rs.getString("image_url"));
    value.put("actionLabel", rs.getString("action_label"));
    value.put("route", rs.getString("route"));
    value.put("priority", rs.getInt("priority"));
    value.put("isActive", rs.getBoolean("active"));
    value.put("startsAt", instant(rs, "starts_at"));
    value.put("endsAt", instant(rs, "ends_at"));
    return value;
  }

  private Map<String, Object> offer(ResultSet rs) throws SQLException {
    Map<String, Object> value = map();
    value.put("id", rs.getString("id"));
    value.put("title", rs.getString("title"));
    value.put("description", rs.getString("description"));
    value.put("code", rs.getString("code"));
    value.put("discountType", rs.getString("discount_type"));
    value.put("discountValue", rs.getBigDecimal("discount_value"));
    value.put("minimumOrder", rs.getBigDecimal("minimum_order"));
    value.put("maximumDiscount", rs.getBigDecimal("maximum_discount"));
    value.put("imageUrl", rs.getString("image_url"));
    value.put("isActive", rs.getBoolean("active"));
    value.put("startsAt", instant(rs, "starts_at"));
    value.put("endsAt", instant(rs, "ends_at"));
    return value;
  }

  private Map<String, Object> farmer(ResultSet rs) throws SQLException {
    Map<String, Object> value = map();
    value.put("id", rs.getString("id"));
    value.put("name", rs.getString("name"));
    value.put("farmName", rs.getString("farm_name"));
    value.put("location", rs.getString("location"));
    value.put("imageUrl", rs.getString("image_url"));
    value.put("rating", rs.getBigDecimal("rating"));
    value.put("reviewCount", rs.getInt("review_count"));
    value.put("isVerified", rs.getBoolean("verified"));
    value.put("experienceYears", rs.getInt("experience_years"));
    value.put("speciality", rs.getString("speciality"));
    return value;
  }

  private Map<String, Object> deliverySlot(ResultSet rs) throws SQLException {
    Map<String, Object> value = map();
    value.put("id", rs.getString("id"));
    value.put("method", rs.getString("method"));
    value.put("label", rs.getString("label"));
    value.put("startTime", rs.getTime("start_time").toLocalTime().toString());
    value.put("endTime", rs.getTime("end_time").toLocalTime().toString());
    value.put("fee", rs.getBigDecimal("fee"));
    value.put("isAvailable", rs.getBoolean("available"));
    value.put("capacity", rs.getInt("capacity"));
    value.put("bookedCount", rs.getInt("booked_count"));
    Date date = rs.getDate("slot_date");
    value.put("date", date == null ? null : date.toLocalDate());
    return value;
  }

  private Map<String, Object> product(ResultSet rs) throws SQLException {
    Map<String, Object> value = map();
    String image = rs.getString("image_url");
    value.put("id", rs.getString("id"));
    value.put("name", rs.getString("name"));
    value.put("englishName", rs.getString("english_name"));
    value.put("teluguName", rs.getString("telugu_name"));
    value.put("description", rs.getString("description"));
    value.put("category", rs.getString("category"));
    value.put("imageUrl", image);
    value.put("images", image == null || image.isBlank() ? List.of() : List.of(image));
    value.put("shoppingMode", "home");
    value.put("unit", rs.getString("unit"));
    value.put("price", rs.getBigDecimal("price"));
    value.put("mrp", rs.getBigDecimal("mrp"));
    value.put("stockQuantity", rs.getInt("stock_quantity"));
    value.put("inStock", rs.getInt("stock_quantity") > 0);
    value.put("isFresh", rs.getBoolean("fresh"));
    value.put("rating", rs.getBigDecimal("rating"));
    value.put("reviewCount", rs.getInt("review_count"));
    value.put("farmerId", "");
    value.put("nutritionInfo", Map.of("Quality", "Farm-fresh and quality checked"));
    value.put("benefits", List.of("Quality checked", "Hygienically packed", "Fresh delivery"));
    value.put("createdAt", instant(rs, "created_at"));
    value.put("updatedAt", instant(rs, "updated_at"));
    return value;
  }

  private Map<String, Object> review(ResultSet rs) throws SQLException {
    Map<String, Object> value = map();
    value.put("id", rs.getObject("id", UUID.class).toString());
    value.put("productId", rs.getString("product_id"));
    value.put("userId", rs.getString("owner_uid"));
    value.put("userName", rs.getString("user_name"));
    value.put("rating", rs.getBigDecimal("rating"));
    value.put("comment", rs.getString("comment"));
    value.put("images", decodeList(rs.getString("image_urls")));
    value.put("isVerifiedPurchase", rs.getBoolean("verified_purchase"));
    value.put("createdAt", instant(rs, "created_at"));
    value.put("updatedAt", instant(rs, "updated_at"));
    return value;
  }


  private Map<String, Object> deliveryPartnerReview(ResultSet rs) throws SQLException {
    Map<String, Object> value = map();
    value.put("id", rs.getObject("id", UUID.class).toString());
    value.put("orderId", rs.getObject("order_id", UUID.class).toString());
    value.put("userId", rs.getString("customer_uid"));
    value.put(
        "deliveryPartnerId",
        rs.getObject("delivery_partner_id", UUID.class).toString());
    value.put("rating", rs.getBigDecimal("rating"));
    value.put("comment", rs.getString("comment"));
    value.put("createdAt", instant(rs, "created_at"));
    value.put("updatedAt", instant(rs, "updated_at"));
    return value;
  }

  private Map<String, Object> notification(ResultSet rs) throws SQLException {
    Map<String, Object> value = map();
    value.put("id", rs.getObject("id", UUID.class).toString());
    value.put("userId", rs.getString("owner_uid"));
    value.put("title", rs.getString("title"));
    value.put("body", rs.getString("body"));
    value.put("type", rs.getString("notification_type"));
    value.put("imageUrl", rs.getString("image_url"));
    value.put("route", rs.getString("route"));
    value.put("data", decodeMap(rs.getString("data_json")));
    value.put("isRead", rs.getBoolean("is_read"));
    value.put("createdAt", instant(rs, "created_at"));
    return value;
  }

  private Map<String, Object> supportTicket(ResultSet rs) throws SQLException {
    Map<String, Object> value = map();
    value.put("id", rs.getObject("id", UUID.class).toString());
    value.put("userId", rs.getString("owner_uid"));
    value.put("subject", rs.getString("subject"));
    value.put("message", rs.getString("message"));
    value.put("category", rs.getString("category"));
    value.put("status", rs.getString("status"));
    value.put("priority", rs.getString("priority"));
    value.put("response", rs.getString("response"));
    value.put("createdAt", instant(rs, "created_at"));
    value.put("updatedAt", instant(rs, "updated_at"));
    return value;
  }

  private Map<String, Object> notificationPreferences(ResultSet rs) throws SQLException {
    Map<String, Object> value = map();
    value.put("orderUpdates", rs.getBoolean("order_updates"));
    value.put("offers", rs.getBoolean("offers"));
    value.put("updatedAt", instant(rs, "updated_at"));
    return value;
  }

  private String encode(Object value) {
    try {
      return json.writeValueAsString(value);
    } catch (JsonProcessingException error) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Invalid JSON data.");
    }
  }

  private List<String> decodeList(String value) {
    if (value == null || value.isBlank()) return List.of();
    try {
      return json.readValue(value, new TypeReference<List<String>>() {});
    } catch (JsonProcessingException error) {
      return List.of();
    }
  }

  private Map<String, Object> decodeMap(String value) {
    if (value == null || value.isBlank()) return Map.of();
    try {
      return json.readValue(value, new TypeReference<Map<String, Object>>() {});
    } catch (JsonProcessingException error) {
      return Map.of();
    }
  }

  private static Instant instant(ResultSet rs, String column) throws SQLException {
    Timestamp value = rs.getTimestamp(column);
    return value == null ? null : value.toInstant();
  }

  private static Map<String, Object> map() {
    return new LinkedHashMap<>();
  }

  private static String clean(String value) {
    return value == null ? "" : value.trim();
  }

  private static String lowerOr(String value, String fallback) {
    String cleaned = clean(value).toLowerCase();
    return cleaned.isEmpty() ? fallback : cleaned;
  }
}
