package com.farmtohome.api.auth;

import com.farmtohome.api.common.ApiException;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EmailOtpService {
  private static final Logger log = LoggerFactory.getLogger(EmailOtpService.class);
  private static final String PURPOSE = "email_verification";
  private static final int OTP_TTL_MINUTES = 10;
  private static final int MAX_VERIFY_ATTEMPTS = 5;
  private static final int MAX_SENDS_PER_HOUR = 5;

  private final JdbcTemplate jdbc;
  private final JavaMailSender mailSender;
  private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
  private final SecureRandom random = new SecureRandom();
  private final String mailHost;
  private final String mailUsername;
  private final String mailPassword;
  private final String mailFrom;

  public EmailOtpService(
      JdbcTemplate jdbc,
      JavaMailSender mailSender,
      @Value("${spring.mail.host:smtp.gmail.com}") String mailHost,
      @Value("${spring.mail.username:veeramallasaipichaiah456@gmail.com}") String mailUsername,
      @Value("${spring.mail.password:zgcdahzwvgdknexf}") String mailPassword,
      @Value("${app.mail-from:veeramallasaipichaiah456@gmail.com}") String mailFrom) {
    this.jdbc = jdbc;
    this.mailSender = mailSender;
    this.mailHost = mailHost != null ? mailHost.trim() : "smtp.gmail.com";
    this.mailUsername = mailUsername != null ? mailUsername.trim() : "veeramallasaipichaiah456@gmail.com";
    this.mailPassword = mailPassword != null ? mailPassword.trim().replaceAll("\\s+", "") : "";
    this.mailFrom = mailFrom != null && !mailFrom.isBlank() ? mailFrom.trim() : this.mailUsername;
    log.info("[SMTP-INIT] SMTP Configured - Host: {}, Username: {}, AppPassword Present: {}, From: {}",
        this.mailHost, mask(this.mailUsername), (this.mailPassword != null && !this.mailPassword.isBlank()), this.mailFrom);
  }

  @Transactional
  public Map<String, Object> send(String uid) {
    UserEmail user = requireUser(uid);

    if (user.emailVerified()) {
      return Map.of(
          "email", mask(user.email()),
          "alreadyVerified", true,
          "expiresInSeconds", 0);
    }

    Integer recent = jdbc.queryForObject("""
        SELECT count(*)
        FROM email_verification_otps
        WHERE firebase_uid = ?
          AND purpose = ?
          AND created_at >= now() - interval '1 hour'
        """, Integer.class, uid, PURPOSE);

    if (recent != null && recent >= MAX_SENDS_PER_HOUR) {
      throw new ApiException(
          HttpStatus.TOO_MANY_REQUESTS,
          "Too many OTP requests. Please try again later.");
    }

    String otp = String.format("%06d", random.nextInt(1_000_000));
    String hash = encoder.encode(otp);
    Instant now = Instant.now();
    Instant expires = now.plus(OTP_TTL_MINUTES, ChronoUnit.MINUTES);

    Integer resendCount = jdbc.queryForObject("""
        SELECT COALESCE(max(resend_count), 0)
        FROM email_verification_otps
        WHERE firebase_uid = ? AND email = ? AND purpose = ?
        """, Integer.class, uid, user.email(), PURPOSE);

    jdbc.update("""
        DELETE FROM email_verification_otps
        WHERE firebase_uid = ?
          AND email = ?
          AND purpose = ?
          AND verified_at IS NULL
        """, uid, user.email(), PURPOSE);

    jdbc.update("""
        INSERT INTO email_verification_otps(
          firebase_uid, email, otp_hash, purpose, expires_at,
          attempts, resend_count, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?)
        """,
        uid,
        user.email(),
        hash,
        PURPOSE,
        Timestamp.from(expires),
        (resendCount == null ? 0 : resendCount) + 1,
        Timestamp.from(now),
        Timestamp.from(now));

    sendMail(user.email(), otp);

    Map<String, Object> result = new LinkedHashMap<>();
    result.put("email", mask(user.email()));
    result.put("alreadyVerified", false);
    result.put("expiresInSeconds", OTP_TTL_MINUTES * 60);
    return result;
  }

  @Transactional
  public Map<String, Object> verify(String uid, String rawOtp) {
    String otp = rawOtp == null ? "" : rawOtp.trim();
    if (!otp.matches("\\d{6}")) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Enter a valid 6-digit OTP.");
    }

    UserEmail user = requireUser(uid);

    if (user.emailVerified()) {
      return Map.of(
          "email", mask(user.email()),
          "verified", true,
          "alreadyVerified", true);
    }

    List<OtpRow> rows = jdbc.query("""
        SELECT id, otp_hash, expires_at, attempts
        FROM email_verification_otps
        WHERE firebase_uid = ?
          AND email = ?
          AND purpose = ?
          AND verified_at IS NULL
        ORDER BY created_at DESC
        LIMIT 1
        """,
        (rs, row) -> new OtpRow(
            rs.getLong("id"),
            rs.getString("otp_hash"),
            rs.getTimestamp("expires_at").toInstant(),
            rs.getInt("attempts")),
        uid, user.email(), PURPOSE);

    if (rows.isEmpty()) {
      throw new ApiException(
          HttpStatus.BAD_REQUEST,
          "No active email OTP found. Request a new OTP.");
    }

    OtpRow row = rows.get(0);

    if (row.expiresAt().isBefore(Instant.now())) {
      throw new ApiException(
          HttpStatus.BAD_REQUEST,
          "Email OTP expired. Request a new OTP.");
    }

    if (row.attempts() >= MAX_VERIFY_ATTEMPTS) {
      throw new ApiException(
          HttpStatus.TOO_MANY_REQUESTS,
          "Too many incorrect attempts. Request a new OTP.");
    }

    if (!encoder.matches(otp, row.otpHash())) {
      jdbc.update("""
          UPDATE email_verification_otps
          SET attempts = attempts + 1, updated_at = now()
          WHERE id = ?
          """, row.id());
      throw new ApiException(HttpStatus.BAD_REQUEST, "Incorrect email OTP.");
    }

    jdbc.update("""
        UPDATE email_verification_otps
        SET verified_at = now(), updated_at = now()
        WHERE id = ?
        """, row.id());

    jdbc.update("""
        UPDATE app_users
        SET email_verified = true, updated_at = now()
        WHERE firebase_uid = ?
        """, uid);

    return Map.of(
        "email", mask(user.email()),
        "verified", true,
        "alreadyVerified", false);
  }

  @Transactional(readOnly = true)
  public Map<String, Object> status(String uid) {
    UserEmail user = requireUser(uid);
    return Map.of(
        "email", mask(user.email()),
        "verified", user.emailVerified());
  }

  @Transactional
  public Map<String, Object> sendForEmail(String rawEmail) {
    String email = rawEmail == null ? "" : rawEmail.trim().toLowerCase();
    if (email.isEmpty() || !email.contains("@")) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Enter a valid email address.");
    }

    List<String> uids = jdbc.query("SELECT firebase_uid FROM app_users WHERE LOWER(email) = LOWER(?)", (rs, rowNum) -> rs.getString("firebase_uid"), email);
    String uid;
    if (uids.isEmpty()) {
      uid = "usr_" + java.util.UUID.randomUUID().toString().replace("-", "").substring(0, 16);
      Instant now = Instant.now();
      jdbc.update("""
          INSERT INTO app_users(firebase_uid, email, display_name, active, created_at, updated_at, last_login_at)
          VALUES (?, ?, ?, true, ?, ?, ?)
          """, uid, email, email.split("@")[0], Timestamp.from(now), Timestamp.from(now), Timestamp.from(now));
    } else {
      uid = uids.get(0);
    }

    Integer recent = jdbc.queryForObject("""
        SELECT count(*)
        FROM email_verification_otps
        WHERE email = ?
          AND purpose = ?
          AND created_at >= now() - interval '1 hour'
        """, Integer.class, email, PURPOSE);

    if (recent != null && recent >= MAX_SENDS_PER_HOUR) {
      throw new ApiException(
          HttpStatus.TOO_MANY_REQUESTS,
          "Too many OTP requests. Please try again later.");
    }

    String otp = String.format("%06d", random.nextInt(1_000_000));
    String hash = encoder.encode(otp);
    Instant now = Instant.now();
    Instant expires = now.plus(OTP_TTL_MINUTES, ChronoUnit.MINUTES);

    Integer resendCount = jdbc.queryForObject("""
        SELECT COALESCE(max(resend_count), 0)
        FROM email_verification_otps
        WHERE email = ? AND purpose = ?
        """, Integer.class, email, PURPOSE);

    jdbc.update("""
        DELETE FROM email_verification_otps
        WHERE email = ?
          AND purpose = ?
          AND verified_at IS NULL
        """, email, PURPOSE);

    jdbc.update("""
        INSERT INTO email_verification_otps(
          firebase_uid, email, otp_hash, purpose, expires_at,
          attempts, resend_count, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?)
        """,
        uid,
        email,
        hash,
        PURPOSE,
        Timestamp.from(expires),
        (resendCount == null ? 0 : resendCount) + 1,
        Timestamp.from(now),
        Timestamp.from(now));

    sendMail(email, otp);

    Map<String, Object> result = new LinkedHashMap<>();
    result.put("email", mask(email));
    result.put("alreadyVerified", false);
    result.put("expiresInSeconds", OTP_TTL_MINUTES * 60);
    return result;
  }

  @Transactional
  public Map<String, Object> verifyForEmail(String rawEmail, String rawOtp) {
    String email = rawEmail == null ? "" : rawEmail.trim().toLowerCase();
    String otp = rawOtp == null ? "" : rawOtp.trim();
    if (!otp.matches("\\d{6}")) {
      throw new ApiException(HttpStatus.BAD_REQUEST, "Enter a valid 6-digit OTP.");
    }

    List<OtpRow> rows = jdbc.query("""
        SELECT id, otp_hash, expires_at, attempts
        FROM email_verification_otps
        WHERE LOWER(email) = LOWER(?)
          AND purpose = ?
          AND verified_at IS NULL
        ORDER BY created_at DESC
        LIMIT 1
        """,
        (rs, row) -> new OtpRow(
            rs.getLong("id"),
            rs.getString("otp_hash"),
            rs.getTimestamp("expires_at").toInstant(),
            rs.getInt("attempts")),
        email, PURPOSE);

    if (rows.isEmpty()) {
      throw new ApiException(
          HttpStatus.BAD_REQUEST,
          "No active email OTP found. Request a new OTP.");
    }

    OtpRow row = rows.get(0);

    if (row.expiresAt().isBefore(Instant.now())) {
      throw new ApiException(
          HttpStatus.BAD_REQUEST,
          "Email OTP expired. Request a new OTP.");
    }

    if (row.attempts() >= MAX_VERIFY_ATTEMPTS) {
      throw new ApiException(
          HttpStatus.TOO_MANY_REQUESTS,
          "Too many incorrect attempts. Request a new OTP.");
    }

    if (!encoder.matches(otp, row.otpHash())) {
      jdbc.update("""
          UPDATE email_verification_otps
          SET attempts = attempts + 1, updated_at = now()
          WHERE id = ?
          """, row.id());
      throw new ApiException(HttpStatus.BAD_REQUEST, "Incorrect email OTP.");
    }

    jdbc.update("""
        UPDATE email_verification_otps
        SET verified_at = now(), updated_at = now()
        WHERE id = ?
        """, row.id());

    jdbc.update("""
        UPDATE app_users
        SET email_verified = true, updated_at = now()
        WHERE LOWER(email) = LOWER(?)
        """, email);

    return Map.of(
        "email", mask(email),
        "verified", true,
        "alreadyVerified", false);
  }

  private UserEmail requireUser(String uid) {
    List<UserEmail> users = jdbc.query("""
        SELECT email, email_verified
        FROM app_users
        WHERE firebase_uid = ? AND active = true
        """,
        (rs, row) -> new UserEmail(
            rs.getString("email"),
            rs.getBoolean("email_verified")),
        uid);

    if (users.isEmpty()) {
      throw new ApiException(HttpStatus.NOT_FOUND, "User profile not found.");
    }

    UserEmail user = users.get(0);
    if (user.email() == null || user.email().isBlank()) {
      throw new ApiException(
          HttpStatus.BAD_REQUEST,
          "No email address is available for this account.");
    }
    return user;
  }

  public Map<String, Object> testSmtpConnection() {
    Map<String, Object> result = new LinkedHashMap<>();
    result.put("mailHost", mailHost);
    result.put("mailUsername", mask(mailUsername));
    result.put("hasPassword", mailPassword != null && !mailPassword.isBlank());

    Map<String, Object> p587 = testPort(mailHost, 587, mailUsername, mailPassword, false);
    result.put("port587_STARTTLS", p587);

    Map<String, Object> p465 = testPort(mailHost, 465, mailUsername, mailPassword, true);
    result.put("port465_SSL", p465);

    boolean connected = Boolean.TRUE.equals(p587.get("connected")) || Boolean.TRUE.equals(p465.get("connected"));
    result.put("smtpConnected", connected);
    result.put("message", connected
        ? "Successfully established connection to Gmail SMTP server."
        : "Failed to connect to Gmail SMTP on both ports 587 and 465.");
    return result;
  }

  private Map<String, Object> testPort(String host, int port, String user, String pass, boolean useSsl) {
    Map<String, Object> status = new LinkedHashMap<>();
    status.put("port", port);
    status.put("protocol", useSsl ? "SSL" : "STARTTLS");
    try {
      JavaMailSenderImpl sender = createSender(host, port, user, pass, useSsl);
      Session session = sender.getSession();
      Transport transport = session.getTransport("smtp");
      transport.connect(host, port, user, pass);
      transport.close();
      status.put("connected", true);
      status.put("status", "SUCCESS");
    } catch (Exception e) {
      status.put("connected", false);
      status.put("status", "FAILED");
      status.put("error", e.getMessage() != null ? e.getMessage() : e.toString());
    }
    return status;
  }

  private JavaMailSenderImpl createSender(String host, int port, String user, String pass, boolean useSsl) {
    JavaMailSenderImpl sender = new JavaMailSenderImpl();
    sender.setHost(host);
    sender.setPort(port);
    sender.setUsername(user);
    sender.setPassword(pass);
    sender.setDefaultEncoding("UTF-8");

    Properties props = sender.getJavaMailProperties();
    props.put("mail.transport.protocol", "smtp");
    props.put("mail.smtp.auth", "true");
    props.put("mail.smtp.connectiontimeout", "8000");
    props.put("mail.smtp.timeout", "8000");
    props.put("mail.smtp.writetimeout", "8000");

    if (useSsl) {
      props.put("mail.smtp.ssl.enable", "true");
      props.put("mail.smtp.ssl.trust", host);
      props.put("mail.smtp.socketFactory.port", String.valueOf(port));
      props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
      props.put("mail.smtp.socketFactory.fallback", "false");
    } else {
      props.put("mail.smtp.starttls.enable", "true");
      props.put("mail.smtp.starttls.required", "true");
      props.put("mail.smtp.ssl.trust", host);
    }
    return sender;
  }

  private void sendMail(String to, String otp) {
    log.info("==========================================");
    log.info("[OTP-DISPATCH] Target Email: {}, Generated OTP: {}", to, otp);
    log.info("==========================================");

    SimpleMailMessage message = new SimpleMailMessage();
    message.setFrom(mailFrom != null && !mailFrom.isBlank() ? mailFrom : mailUsername);
    message.setTo(to);
    message.setSubject("Farm To Home - Email Verification OTP");
    message.setText(
        "Your Farm To Home verification OTP is: " + otp + "\n\n"
            + "This OTP expires in " + OTP_TTL_MINUTES + " minutes.\n"
            + "Do not share this OTP with anyone.");

    // Strategy 1: Primary configured mailSender
    try {
      log.info("[SMTP] Strategy 1: Attempting send via primary mailSender to {}...", to);
      mailSender.send(message);
      log.info("[SMTP] Strategy 1 SUCCESS: Primary mailSender delivered OTP to {}", to);
      return;
    } catch (Exception err1) {
      log.warn("[SMTP] Strategy 1 (Primary) failed for {}: {}", to, err1.getMessage());
    }

    // Strategy 2: Explicit Port 587 (STARTTLS)
    try {
      log.info("[SMTP] Strategy 2: Attempting send via Port 587 STARTTLS to {}...", to);
      JavaMailSenderImpl sender587 = createSender(mailHost, 587, mailUsername, mailPassword, false);
      sender587.send(message);
      log.info("[SMTP] Strategy 2 SUCCESS: Port 587 STARTTLS delivered OTP to {}", to);
      return;
    } catch (Exception err2) {
      log.warn("[SMTP] Strategy 2 (Port 587 STARTTLS) failed for {}: {}", to, err2.getMessage());
    }

    // Strategy 3: Explicit Port 465 (SSL)
    try {
      log.info("[SMTP] Strategy 3: Attempting send via Port 465 SSL to {}...", to);
      JavaMailSenderImpl sender465 = createSender(mailHost, 465, mailUsername, mailPassword, true);
      sender465.send(message);
      log.info("[SMTP] Strategy 3 SUCCESS: Port 465 SSL delivered OTP to {}", to);
      return;
    } catch (Exception err3) {
      log.error("[SMTP] Strategy 3 (Port 465 SSL) failed for {}: {}", to, err3.getMessage(), err3);
      throw new ApiException(
          HttpStatus.INTERNAL_SERVER_ERROR,
          "Failed to deliver OTP email via Gmail SMTP (Ports 587 & 465 failed). Error: " + err3.getMessage());
    }
  }

  private String mask(String email) {
    int at = email.indexOf('@');
    if (at <= 1) return email;
    String local = email.substring(0, at);
    return local.substring(0, 1)
        + "***"
        + local.substring(local.length() - 1)
        + email.substring(at);
  }

  private record UserEmail(String email, boolean emailVerified) {}
  private record OtpRow(long id, String otpHash, Instant expiresAt, int attempts) {}
}
