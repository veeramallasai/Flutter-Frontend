import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/cart_model.dart';
import '../../providers/cart_provider.dart';
import 'widgets/cart_coupon_section.dart';
import 'widgets/cart_header.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_mode_warning.dart';
import 'widgets/cart_price_summary.dart';
import 'widgets/cart_savings_card.dart';
import 'widgets/proceed_checkout_bar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CartProvider()..listenToCart();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon(String code) async {
    final CartModel? cart = _provider.cart;
    final String coupon = code.trim().toUpperCase();
    if (cart == null || coupon.isEmpty) {
      _showMessage('Enter a coupon code.');
      return;
    }

    double discount;
    if (coupon == 'FRESH10') {
      discount = (cart.subtotal * 0.10).clamp(0, 100).toDouble();
    } else if (coupon == 'WELCOME50' && cart.subtotal >= 299) {
      discount = 50;
    } else {
      _showMessage(
        coupon == 'WELCOME50'
            ? 'WELCOME50 requires a minimum cart value of ₹299.'
            : 'This coupon is not valid.',
      );
      return;
    }

    final bool success = await _provider.applyCoupon(coupon, discount);
    if (!success)
      _showMessage(_provider.errorMessage ?? 'Unable to apply coupon.');
  }

  Future<void> _removeCoupon() async {
    final bool success = await _provider.applyCoupon('', 0);
    if (!success)
      _showMessage(_provider.errorMessage ?? 'Unable to remove coupon.');
  }

  Future<void> _clearCart() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Clear cart?'),
            content: const Text('All products will be removed from your cart.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('CLEAR'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    final bool success = await _provider.clearCart();
    if (!success)
      _showMessage(_provider.errorMessage ?? 'Unable to clear cart.');
  }

  void _openDelivery(CartModel cart) {
    Navigator.pushNamed(
      context,
      AppRoutes.deliveryMethod,
      arguments: <String, dynamic>{
        'shoppingMode': cart.shoppingMode,
        'subtotal': cart.subtotal,
        'savings': cart.productSavings + cart.couponDiscount,
        'total': cart.total,
        'itemCount': cart.itemCount,
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (BuildContext context, Widget? child) {
        final CartModel? cart = _provider.cart;
        final CartModel activeCart = cart ?? CartModel.empty('');
        final bool empty = activeCart.isEmpty;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Fresh Cart'),
                Text(
                  'Quality checked • Secure checkout',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          body:
              _provider.isLoading && cart == null
                  ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                  : _provider.hasError && cart == null
                  ? _CartError(
                    message: _provider.errorMessage ?? 'Unable to load cart.',
                    onRetry: _provider.listenToCart,
                  )
                  : empty
                  ? _EmptyCart(
                    onShopNow:
                        () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (Route<dynamic> route) => false,
                        ),
                  )
                  : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      _provider.listenToCart();
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                      children: <Widget>[
                        _CartHero(
                          total: activeCart.total,
                          itemCount: activeCart.itemCount,
                          shoppingMode: activeCart.shoppingMode,
                        ),
                        const SizedBox(height: 15),
                        CartHeader(
                          itemCount: activeCart.itemCount,
                          shoppingMode: activeCart.shoppingMode,
                          onClear: _provider.isUpdating ? null : _clearCart,
                        ),
                        const SizedBox(height: 14),
                        CartModeWarning(
                          hasMixedModes:
                              activeCart.items
                                  .map(
                                    (CartItemModel item) => item.shoppingMode,
                                  )
                                  .toSet()
                                  .length >
                              1,
                          shoppingMode: activeCart.shoppingMode,
                        ),
                        if (activeCart.items
                                .map((CartItemModel item) => item.shoppingMode)
                                .toSet()
                                .length >
                            1)
                          const SizedBox(height: 12),
                        ...activeCart.items.map(
                          (CartItemModel item) => Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: CartItemCard(
                              item: item,
                              enabled: !_provider.isUpdating,
                              onDecrease:
                                  () => _provider.updateQuantity(
                                    item.id,
                                    item.quantity - 1,
                                  ),
                              onIncrease:
                                  () => _provider.updateQuantity(
                                    item.id,
                                    item.quantity + 1,
                                  ),
                              onRemove: () => _provider.removeItem(item.id),
                            ),
                          ),
                        ),
                        CartSavingsCard(
                          productSavings: activeCart.productSavings,
                          couponSavings: activeCart.couponDiscount,
                        ),
                        if (activeCart.productSavings +
                                activeCart.couponDiscount >
                            0)
                          const SizedBox(height: 13),
                        CartCouponSection(
                          currentCode: activeCart.couponCode,
                          discount: activeCart.couponDiscount,
                          isLoading: _provider.isUpdating,
                          onApply: _applyCoupon,
                          onRemove: _removeCoupon,
                        ),
                        const SizedBox(height: 13),
                        CartPriceSummary(
                          subtotal:
                              activeCart.subtotal + activeCart.productSavings,
                          productSavings: activeCart.productSavings,
                          couponDiscount: activeCart.couponDiscount,
                          total: activeCart.total,
                        ),
                      ],
                    ),
                  ),
          bottomNavigationBar:
              empty
                  ? null
                  : ProceedCheckoutBar(
                    total: activeCart.total,
                    itemCount: activeCart.itemCount,
                    isLoading: _provider.isUpdating,
                    onProceed: () => _openDelivery(activeCart),
                  ),
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onShopNow});

  final VoidCallback onShopNow;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.shopping_basket_outlined,
              color: AppColors.primary,
              size: 68,
            ),
            const SizedBox(height: 14),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add fresh products directly from local farmers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
            ),
            const SizedBox(height: 17),
            FilledButton.icon(
              onPressed: onShopNow,
              icon: const Icon(Icons.eco_rounded),
              label: const Text('SHOP NOW'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartHero extends StatelessWidget {
  const _CartHero({
    required this.total,
    required this.itemCount,
    required this.shoppingMode,
  });

  final double total;
  final int itemCount;
  final String shoppingMode;

  @override
  Widget build(BuildContext context) {
    const double target = 499;
    final double remaining = (target - total).clamp(0, target).toDouble();
    final double progress = (total / target).clamp(0, 1).toDouble();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF1B5E20),
            Color(0xFF2E7D32),
            Color(0xFF2E7D32),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x260B7A3E),
            blurRadius: 24,
            offset: Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shopping_basket_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$itemCount farm-fresh item${itemCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shoppingMode == 'shop'
                          ? 'Bulk pricing is active for this cart'
                          : 'Packed fresh for your home',
                      style: const TextStyle(
                        color: Color(0xFFD4F1E1),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFFFFB300),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFB300),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Icon(
                remaining <= 0
                    ? Icons.celebration_rounded
                    : Icons.local_shipping_rounded,
                color: Colors.white,
                size: 15,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  remaining <= 0
                      ? 'You unlocked FREE quick delivery'
                      : 'Add ₹${remaining.toStringAsFixed(0)} more for FREE quick delivery',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartError extends StatelessWidget {
  const _CartError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 52,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('TRY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
