class DeliveryConstants {
  DeliveryConstants._();

  static const String quick = 'quick';
  static const String scheduled = 'scheduled';
  static const String preorder = 'preorder';

  static const double freeDeliveryThreshold = 499;
  static const double quickDeliveryFee = 35;
  static const double scheduledDeliveryFee = 20;
  static const double preorderDeliveryFee = 0;

  static const Duration quickDeliveryEta = Duration(minutes: 45);
  static const int maximumScheduleDays = 7;
  static const int preorderLeadDays = 2;

  static const List<String> methods = <String>[quick, scheduled, preorder];
  static const List<String> scheduledSlots = <String>[
    '07:00 AM - 09:00 AM',
    '09:00 AM - 11:00 AM',
    '11:00 AM - 01:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
    '06:00 PM - 08:00 PM',
  ];
}
