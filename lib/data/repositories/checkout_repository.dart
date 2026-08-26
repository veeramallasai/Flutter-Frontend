import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_model.dart';
import '../models/coupon_model.dart';

class CheckoutRepository {
  CheckoutRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  List<CouponModel> get localCoupons => const <CouponModel>[
    CouponModel(
      id: 'fresh10',
      code: 'FRESH10',
      title: '10% fresh savings',
      description: 'Get 10% off up to ₹100',
      discountValue: 10,
      minimumOrder: 299,
      maximumDiscount: 100,
    ),
    CouponModel(
      id: 'farm50',
      code: 'FARM50',
      title: 'Flat ₹50 off',
      description: 'Save ₹50 on orders above ₹499',
      discountType: 'fixed',
      discountValue: 50,
      minimumOrder: 499,
    ),
  ];

  Future<CouponModel?> findCoupon(String code) async {
    final String normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection('coupons')
              .where('code', isEqualTo: normalized)
              .limit(1)
              .get();
      if (snapshot.docs.isNotEmpty)
        return CouponModel.fromDocument(snapshot.docs.first);
    } catch (_) {
      // Local offers keep checkout usable when Firestore is unavailable.
    }
    for (final CouponModel coupon in localCoupons) {
      if (coupon.code == normalized) return coupon;
    }
    return null;
  }

  Future<double> validateAndCalculateCoupon({
    required String code,
    required double subtotal,
  }) async {
    final CouponModel? coupon = await findCoupon(code);
    if (coupon == null) throw StateError('Coupon code is not valid.');
    if (!coupon.isCurrentlyValid)
      throw StateError('This coupon is no longer available.');
    if (subtotal < coupon.minimumOrder) {
      throw StateError(
        'Add ₹${(coupon.minimumOrder - subtotal).ceil()} more to use this coupon.',
      );
    }
    return coupon.discountFor(subtotal);
  }

  double deliveryFee({
    required double subtotal,
    String deliveryMethod = 'quick',
  }) {
    if (subtotal >= 499) return 0;
    switch (deliveryMethod.trim().toLowerCase()) {
      case 'scheduled':
        return 20;
      case 'preorder':
      case 'pre_order':
        return 0;
      default:
        return 35;
    }
  }

  Map<String, double> priceBreakdown({
    required CartModel cart,
    required String deliveryMethod,
    double couponDiscount = 0,
  }) {
    final double fee = deliveryFee(
      subtotal: cart.subtotal,
      deliveryMethod: deliveryMethod,
    );
    final double safeDiscount =
        couponDiscount.clamp(0, cart.subtotal).toDouble();
    return <String, double>{
      'mrpTotal': cart.subtotal + cart.productSavings,
      'subtotal': cart.subtotal,
      'productSavings': cart.productSavings,
      'couponDiscount': safeDiscount,
      'deliveryFee': fee,
      'total':
          (cart.subtotal - safeDiscount + fee)
              .clamp(0, double.infinity)
              .toDouble(),
    };
  }
}
