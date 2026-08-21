import 'package:flutter/material.dart';

import '../features/address/address_list_screen.dart';
import '../features/address/add_address_screen.dart';
import '../features/address/edit_address_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/auth_flow_screen.dart';
import '../features/auth/complete_profile_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/categories/category_products_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/delivery/delivery_method_screen.dart';
import '../features/delivery/preorder_delivery_screen.dart';
import '../features/delivery/quick_delivery_screen.dart';
import '../features/delivery/scheduled_delivery_screen.dart';
import '../features/home/home_screen.dart';
import '../features/orders/order_confirmation_screen.dart';
import '../features/orders/order_details_screen.dart';
import '../features/orders/order_tracking_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/payment/payment_screen.dart';
import '../features/product/product_details_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/notifications_screen.dart';
import '../features/profile/privacy_screen.dart';
import '../features/profile/saved_addresses_screen.dart';
import '../features/profile/support_screen.dart';
import '../features/profile/terms_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../data/models/address_model.dart';

import 'app_routes.dart';
import 'session_gate.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashScreen(), settings);

      case AppRoutes.session:
        return _page(const SessionGate(), settings);

      case AppRoutes.authFlow:
        return _page(const AuthFlowScreen(), settings);

      case AppRoutes.completeProfile:
        return _page(const CompleteProfileScreen(), settings);

      case AppRoutes.login:
        return _page(const LoginScreen(), settings);

      case AppRoutes.register:
        return _page(const RegisterScreen(), settings);

      case AppRoutes.forgotPassword:
        return _page(const ForgotPasswordScreen(), settings);

      case AppRoutes.otp:
        final Map<String, dynamic> args = _getArguments(settings);

        return _page(
          OtpScreen(
            phoneNumber: (args['phoneNumber'] ?? '').toString(),
            email: args['email']?.toString(),
            emailVerificationSent: args['emailVerificationSent'] != false,
            userId: args['userId']?.toString(),
            source: args['source']?.toString(),
          ),
          settings,
        );

      case AppRoutes.home:
        return _page(const HomeScreen(), settings);

      case AppRoutes.categories:
        final Map<String, dynamic> args = _getArguments(settings);

        return _page(
          CategoriesScreen(
            initialShoppingMode:
            (args['shoppingMode'] ?? 'home').toString(),
          ),
          settings,
        );

      case AppRoutes.categoryProducts:
        final Map<String, dynamic> args = _getArguments(settings);
        final String category = (args['category'] ?? '').toString();
        final String title = (args['title'] ?? category).toString();

        return _page(
          CategoryProductsScreen(
            category: category,
            title: title,
            initialShoppingMode:
            (args['shoppingMode'] ?? 'home').toString(),
          ),
          settings,
        );

      case AppRoutes.productDetails:
        final Map<String, dynamic> args = _getArguments(settings);

        return _page(
          ProductDetailsScreen(
            productId: (args['productId'] ?? '').toString(),
            initialShoppingMode:
            (args['shoppingMode'] ?? 'home').toString(),
          ),
          settings,
        );

      case AppRoutes.cart:
        return _page(const CartScreen(), settings);

      case AppRoutes.search:
        return _page(const SearchScreen(), settings);

      case AppRoutes.profile:
        return _page(const ProfileScreen(), settings);

      case AppRoutes.editProfile:
        return _page(const EditProfileScreen(), settings);

      case AppRoutes.notifications:
        return _page(const NotificationsScreen(), settings);

      case AppRoutes.savedAddresses:
        return _page(const SavedAddressesScreen(), settings);

      case AppRoutes.support:
        return _page(const SupportScreen(), settings);

      case AppRoutes.privacy:
        return _page(const PrivacyScreen(), settings);

      case AppRoutes.terms:
        return _page(const TermsScreen(), settings);

      case AppRoutes.settings:
        return _page(const SettingsScreen(), settings);

      case AppRoutes.deliveryMethod:
        final Map<String, dynamic> args = _getArguments(settings);

        return _page(
          DeliveryMethodScreen(
            initialShoppingMode:
            (args['shoppingMode'] ?? 'home').toString(),
            subtotal: _toDouble(args['subtotal']),
            savings: _toDouble(args['savings']),
            total: _toDouble(args['total']),
            itemCount: _toInt(args['itemCount']),
          ),
          settings,
        );

      case AppRoutes.quickDelivery:
        final Map<String, dynamic> args = _getArguments(settings);
        return _page(
          QuickDeliveryScreen(
            shoppingMode: (args['shoppingMode'] ?? 'home').toString(),
            subtotal: _toDouble(args['subtotal']),
            savings: _toDouble(args['savings']),
            total: _toDouble(args['total']),
            itemCount: _toInt(args['itemCount']),
          ),
          settings,
        );

      case AppRoutes.scheduledDelivery:
        final Map<String, dynamic> args = _getArguments(settings);
        return _page(
          ScheduledDeliveryScreen(
            shoppingMode: (args['shoppingMode'] ?? 'home').toString(),
            subtotal: _toDouble(args['subtotal']),
            savings: _toDouble(args['savings']),
            total: _toDouble(args['total']),
            itemCount: _toInt(args['itemCount']),
          ),
          settings,
        );

      case AppRoutes.preorderDelivery:
        final Map<String, dynamic> args = _getArguments(settings);
        return _page(
          PreorderDeliveryScreen(
            shoppingMode: (args['shoppingMode'] ?? 'home').toString(),
            subtotal: _toDouble(args['subtotal']),
            savings: _toDouble(args['savings']),
            total: _toDouble(args['total']),
            itemCount: _toInt(args['itemCount']),
          ),
          settings,
        );

      case AppRoutes.addresses:
        final Map<String, dynamic> args = _getArguments(settings);

        return _page(
          AddressesScreen(
            shoppingMode: (args['shoppingMode'] ?? 'home').toString(),
            deliveryMethod: (args['deliveryMethod'] ?? 'quick').toString(),
            deliveryDate: args['deliveryDate']?.toString(),
            deliverySlot:
            (args['deliverySlot'] ?? 'Earliest available').toString(),
            subtotal: _toDouble(args['subtotal']),
            savings: _toDouble(args['savings']),
            total: _toDouble(args['total']),
            itemCount: _toInt(args['itemCount']),
          ),
          settings,
        );

      case AppRoutes.addAddress:
        return _page(const AddAddressScreen(), settings);

      case AppRoutes.editAddress:
        final Map<String, dynamic> args = _getArguments(settings);
        final Object? address = args['address'];
        if (address is AddressModel) {
          return _page(EditAddressScreen(address: address), settings);
        }
        return _page(
          const _RouteMessageScreen(
            title: 'Edit Address',
            message: 'Select an address to edit.',
          ),
          settings,
        );

      case AppRoutes.checkout:
        final Map<String, dynamic> args = _getArguments(settings);

        return _page(
          CheckoutScreen(
            shoppingMode: (args['shoppingMode'] ?? 'home').toString(),
            deliveryMethod: (args['deliveryMethod'] ?? 'quick').toString(),
            deliveryDate: args['deliveryDate']?.toString(),
            deliverySlot:
            (args['deliverySlot'] ?? 'Earliest available').toString(),
            addressId: (args['addressId'] ?? '').toString(),
            address: _toStringDynamicMap(args['address']),
            subtotal: _toDouble(args['subtotal']),
            savings: _toDouble(args['savings']),
            total: _toDouble(args['total']),
            itemCount: _toInt(args['itemCount']),
          ),
          settings,
        );

      case AppRoutes.payment:
        final Map<String, dynamic> args = _getArguments(settings);

        return _page(
          PaymentScreen(
            shoppingMode: (args['shoppingMode'] ?? 'home').toString(),
            deliveryMethod: (args['deliveryMethod'] ?? 'quick').toString(),
            deliveryDate: args['deliveryDate']?.toString(),
            deliverySlot:
            (args['deliverySlot'] ?? 'Earliest available').toString(),
            addressId: (args['addressId'] ?? '').toString(),
            address: _toStringDynamicMap(args['address']),
            subtotal: _toDouble(args['subtotal']),
            productSavings: _toDouble(args['productSavings']),
            couponCode: (args['couponCode'] ?? '').toString(),
            couponDiscount: _toDouble(args['couponDiscount']),
            deliveryFee: _toDouble(args['deliveryFee']),
            grandTotal: _toDouble(args['grandTotal']),
            itemCount: _toInt(args['itemCount']),
          ),
          settings,
        );

      case AppRoutes.orders:
        return _page(const OrdersScreen(), settings);

      case AppRoutes.orderDetails:
        final Map<String, dynamic> args = _getArguments(settings);
        return _page(
          OrderDetailsScreen(orderId: (args['orderId'] ?? '').toString()),
          settings,
        );

      case AppRoutes.orderTracking:
        final Map<String, dynamic> args = _getArguments(settings);
        return _page(
          OrderTrackingScreen(orderId: (args['orderId'] ?? '').toString()),
          settings,
        );

      case AppRoutes.orderConfirmation:
        final Map<String, dynamic> args = _getArguments(settings);

        return _page(
          OrderConfirmationScreen(arguments: args),
          settings,
        );

      default:
        return _page(
          _RouteNotFoundScreen(routeName: settings.name ?? ''),
          settings,
        );
    }
  }

  static Map<String, dynamic> _getArguments(RouteSettings settings) {
    final Object? value = settings.arguments;

    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return value.map(
            (dynamic key, dynamic item) =>
            MapEntry<String, dynamic>(key.toString(), item),
      );
    }

    return <String, dynamic>{};
  }

  static Map<String, dynamic> _toStringDynamicMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return value.map(
            (dynamic key, dynamic item) =>
            MapEntry<String, dynamic>(key.toString(), item),
      );
    }

    return <String, dynamic>{};
  }

  static MaterialPageRoute<dynamic> _page(
      Widget screen,
      RouteSettings settings,
      ) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (BuildContext context) => screen,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen({required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x140A5B32),
                    blurRadius: 32,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F7EE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.explore_off_rounded,
                        size: 36,
                        color: Color(0xFF087A3E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Page not found',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      routeName.isEmpty
                          ? 'The requested page is unavailable.'
                          : 'The requested route “$routeName” is unavailable.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context)
                            .pushNamedAndRemoveUntil(
                          AppRoutes.home,
                          (Route<dynamic> route) => false,
                        ),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('BACK TO HOME'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF087A3E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteMessageScreen extends StatelessWidget {
  const _RouteMessageScreen({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
