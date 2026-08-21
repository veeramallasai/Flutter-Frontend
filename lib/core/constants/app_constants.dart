class AppConstants {
  AppConstants._();

  static const String appName = 'Farm To Home';
  static const String appTagline = 'Fresh from farms, delivered with care';
  static const String currencySymbol = '₹';
  static const String countryCode = '+91';
  static const String country = 'India';
  static const String defaultLanguage = 'en';
  static const String teluguLanguage = 'te';
  static const String supportEmail = 'support@farmtohome.app';
  static const String supportPhone = '1800-000-000';

  static const int otpLength = 6;
  static const int phoneLength = 10;
  static const int pincodeLength = 6;
  static const int searchDebounceMilliseconds = 350;
  static const int defaultPageSize = 20;
  static const int maximumCartQuantity = 99;

  static const Duration otpTimeout = Duration(seconds: 60);
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration splashDuration = Duration(milliseconds: 2200);
}
