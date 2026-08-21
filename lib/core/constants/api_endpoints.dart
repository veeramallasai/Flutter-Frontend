class ApiEndpoints {
  ApiEndpoints._();

  static const String apiVersion = 'v1';
  static const String health = '/health';
  static const String auth = '/$apiVersion/auth';
  static const String users = '/$apiVersion/users';
  static const String products = '/$apiVersion/products';
  static const String categories = '/$apiVersion/categories';
  static const String cart = '/$apiVersion/cart';
  static const String checkout = '/$apiVersion/checkout';
  static const String orders = '/$apiVersion/orders';
  static const String payments = '/$apiVersion/payments';
  static const String deliverySlots = '/$apiVersion/delivery-slots';
  static const String addresses = '/$apiVersion/addresses';
  static const String reviews = '/$apiVersion/reviews';
  static const String notifications = '/$apiVersion/notifications';
  static const String support = '/$apiVersion/support';

  static String product(String productId) => '$products/${productId.trim()}';
  static String order(String orderId) => '$orders/${orderId.trim()}';
  static String payment(String paymentId) => '$payments/${paymentId.trim()}';
}
