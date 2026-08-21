import 'package:flutter/foundation.dart';

import '../data/models/cart_model.dart';
import '../data/repositories/checkout_repository.dart';

class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider({CheckoutRepository? repository})
      : _repository = repository ?? CheckoutRepository();

  final CheckoutRepository _repository;
  CartModel? _cart;
  String _deliveryMethod = 'quick';
  String _couponCode = '';
  double _couponDiscount = 0;
  bool _isApplyingCoupon = false;
  String? _errorMessage;

  CartModel? get cart => _cart;
  String get deliveryMethod => _deliveryMethod;
  String get couponCode => _couponCode;
  double get couponDiscount => _couponDiscount;
  bool get isApplyingCoupon => _isApplyingCoupon;
  String? get errorMessage => _errorMessage;

  Map<String, double> get priceBreakdown {
    final CartModel? value = _cart;
    return value == null
        ? <String, double>{}
        : _repository.priceBreakdown(
            cart: value,
            deliveryMethod: _deliveryMethod,
            couponDiscount: _couponDiscount,
          );
  }

  void initialize(CartModel cart, {String deliveryMethod = 'quick'}) {
    _cart = cart;
    _deliveryMethod = deliveryMethod.trim().toLowerCase();
    _couponCode = cart.couponCode;
    _couponDiscount = cart.couponDiscount;
    notifyListeners();
  }

  void setDeliveryMethod(String value) {
    _deliveryMethod = value.trim().toLowerCase();
    notifyListeners();
  }

  Future<bool> applyCoupon(String code) async {
    final CartModel? value = _cart;
    if (value == null || _isApplyingCoupon) return false;
    _isApplyingCoupon = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _couponDiscount = await _repository.validateAndCalculateCoupon(
        code: code,
        subtotal: value.subtotal,
      );
      _couponCode = code.trim().toUpperCase();
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Bad state: ', '');
      return false;
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  void removeCoupon() {
    _couponCode = '';
    _couponDiscount = 0;
    _errorMessage = null;
    notifyListeners();
  }
}
