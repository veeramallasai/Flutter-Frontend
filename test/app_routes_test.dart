import 'package:flutter_test/flutter_test.dart';
import 'package:farm_to_home_app/app/app_routes.dart';

void main() {
  test('all production routes are non-empty and unique', () {
    const List<String> routes = <String>[
      AppRoutes.splash,
      AppRoutes.session,
      AppRoutes.authFlow,
      AppRoutes.completeProfile,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.otp,
      AppRoutes.forgotPassword,
      AppRoutes.home,
      AppRoutes.categories,
      AppRoutes.categoryProducts,
      AppRoutes.search,
      AppRoutes.productDetails,
      AppRoutes.cart,
      AppRoutes.deliveryMethod,
      AppRoutes.quickDelivery,
      AppRoutes.scheduledDelivery,
      AppRoutes.preorderDelivery,
      AppRoutes.addresses,
      AppRoutes.addAddress,
      AppRoutes.editAddress,
      AppRoutes.checkout,
      AppRoutes.payment,
      AppRoutes.orderConfirmation,
      AppRoutes.orders,
      AppRoutes.orderDetails,
      AppRoutes.orderTracking,
      AppRoutes.profile,
      AppRoutes.editProfile,
      AppRoutes.notifications,
      AppRoutes.savedAddresses,
      AppRoutes.support,
      AppRoutes.privacy,
      AppRoutes.terms,
      AppRoutes.settings,
    ];

    expect(routes.every((String route) => route.startsWith('/')), isTrue);
    expect(routes.toSet().length, routes.length);
  });
}
