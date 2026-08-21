import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';
import 'widgets/checkout_address_section.dart';
import 'widgets/checkout_coupon_section.dart';
import 'widgets/checkout_delivery_section.dart';
import 'widgets/checkout_items_section.dart';
import 'widgets/checkout_price_breakdown.dart';
import 'widgets/continue_payment_bar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    this.shoppingMode = 'home',
    this.deliveryMethod = 'quick',
    this.deliveryDate,
    this.deliverySlot = 'Earliest available',
    this.addressId = '',
    this.address = const <String, dynamic>{},
    this.subtotal = 0,
    this.savings = 0,
    this.total = 0,
    this.itemCount = 0,
  });

  final String shoppingMode;
  final String deliveryMethod;
  final String? deliveryDate;
  final String deliverySlot;

  final String addressId;
  final Map<String, dynamic> address;

  final double subtotal;
  final double savings;
  final double total;
  final int itemCount;

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState
    extends State<CheckoutScreen> {
  final CartRepository _cartRepository = CartRepository();
  final TextEditingController _couponController =
  TextEditingController();

  late Future<CartModel> _cartFuture;

  String? _couponCode;

  double _couponDiscount = 0;

  bool _applyingCoupon = false;
  bool _continuing = false;

  User? get _user =>
      FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartRepository.getCart();
  }

  void _reloadCart() {
    setState(() {
      _cartFuture = _cartRepository.getCart();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _go(
      String route, {
        Object? arguments,
      }) {
    Navigator.of(context).pushNamed(
      route,
      arguments: arguments,
    );
  }

  void _showMessage(
      String message, {
        bool error = false,
      }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor:
          error ? AppColors.error : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
  }

  Future<void> _applyCoupon() async {
    final String code =
    _couponController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showMessage(
        'Enter a coupon code.',
        error: true,
      );
      return;
    }

    if (_applyingCoupon) {
      return;
    }

    setState(() {
      _applyingCoupon = true;
    });

    try {
      await _cartRepository.applyCoupon(code, 0);
      final CartModel cart = await _cartRepository.getCart();

      if (!mounted) {
        return;
      }

      setState(() {
        _couponCode = code;
        _couponDiscount = cart.couponDiscount;
        _cartFuture = Future<CartModel>.value(cart);
      });

      _showMessage(
        'Coupon $code applied successfully.',
      );
    } catch (_) {
      _showMessage(
        'Unable to apply coupon.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _applyingCoupon = false;
        });
      }
    }
  }

  Future<void> _removeCoupon() async {
    try {
      await _cartRepository.removeCoupon();
      final CartModel cart = await _cartRepository.getCart();
      if (!mounted) return;
      setState(() {
        _couponCode = null;
        _couponDiscount = 0;
        _couponController.clear();
        _cartFuture = Future<CartModel>.value(cart);
      });
    } catch (_) {
      _showMessage('Unable to remove coupon.', error: true);
    }
  }

  void _continueToPayment(
      List<_CheckoutCartItem> items,
      ) {
    if (_continuing) {
      return;
    }

    if (items.isEmpty) {
      _showMessage(
        'Your cart is empty.',
        error: true,
      );
      return;
    }

    if (widget.address.isEmpty ||
        widget.addressId.isEmpty) {
      _showMessage(
        'Please select a delivery address.',
        error: true,
      );
      return;
    }

    final bool hasOutOfStock =
    items.any(
          (_CheckoutCartItem item) =>
      !item.inStock,
    );

    if (hasOutOfStock) {
      _showMessage(
        'Remove out-of-stock products before continuing.',
        error: true,
      );
      return;
    }

    final bool wrongMode =
    items.any(
          (_CheckoutCartItem item) =>
      item.shoppingMode != widget.shoppingMode,
    );

    if (wrongMode) {
      _showMessage(
        'Your cart contains items from another shopping mode.',
        error: true,
      );
      return;
    }

    final _CheckoutTotals totals =
    _CheckoutTotals.fromItems(
      items,
      couponDiscount: _couponDiscount,
    );

    setState(() {
      _continuing = true;
    });

    _go(
      AppRoutes.payment,
      arguments: <String, dynamic>{
        'shoppingMode':
        widget.shoppingMode,
        'deliveryMethod':
        widget.deliveryMethod,
        'deliveryDate':
        widget.deliveryDate,
        'deliverySlot':
        widget.deliverySlot,
        'addressId':
        widget.addressId,
        'address':
        widget.address,
        'subtotal':
        totals.subtotal,
        'productSavings':
        totals.productSavings,
        'couponCode':
        _couponCode,
        'couponDiscount':
        _couponDiscount,
        'deliveryFee':
        totals.deliveryFee,
        'grandTotal':
        totals.grandTotal,
        'itemCount':
        totals.quantity,
      },
    );

    if (mounted) {
      setState(() {
        _continuing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _user;

    if (user == null) {
      return _LoginRequired(
        onLogin: () {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(
            AppRoutes.login,
                (
                Route<dynamic> route,
                ) =>
            false,
          );
        },
      );
    }

    return Scaffold(
      backgroundColor:
      AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildHeader(),
            Expanded(
              child: FutureBuilder<CartModel>(
                future: _cartFuture,
                builder: (
                    BuildContext context,
                    AsyncSnapshot<CartModel> snapshot,
                    ) {
                  if (snapshot
                      .connectionState ==
                      ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return _ErrorView(
                      onRetry: _reloadCart,
                    );
                  }

                  final List<_CheckoutCartItem> items =
                      (snapshot.data?.items ?? const <CartItemModel>[])
                      .map(
                        (CartItemModel item) =>
                            _CheckoutCartItem.fromMap(item.toMap()),
                      )
                      .toList(growable: false);

                  if (items.isEmpty) {
                    return _EmptyCheckout(
                      onShop: () {
                        _go(
                          AppRoutes
                              .categories,
                        );
                      },
                    );
                  }

                  return _buildCheckout(
                    items,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration:
      const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Back',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color:
              const Color(0xFFEAF7EF),
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons
                  .shopping_cart_checkout_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Checkout',
                  style: TextStyle(
                    color:
                    AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Review your order before payment',
                  style: TextStyle(
                    color: AppColors
                        .textSecondary,
                    fontSize: 10.5,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cart',
            onPressed: () {
              _go(
                AppRoutes.cart,
              );
            },
            icon: const Icon(
              Icons
                  .shopping_bag_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckout(
      List<_CheckoutCartItem> items,
      ) {
    final double width =
        MediaQuery.sizeOf(context).width;

    final bool desktop =
        width >= 1000;

    final _CheckoutTotals totals =
    _CheckoutTotals.fromItems(
      items,
      couponDiscount:
      _couponDiscount,
    );

    final Widget mainContent =
    Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: <Widget>[
        _buildHero(),

        const SizedBox(height: 25),

        _buildProgress(),

        const SizedBox(height: 26),

        _buildAddressCard(),

        const SizedBox(height: 16),

        _buildDeliveryCard(),

        const SizedBox(height: 25),

        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Order items',
                style: TextStyle(
                  color: AppColors
                      .textPrimary,
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${totals.quantity} item${totals.quantity == 1 ? '' : 's'}',
              style: const TextStyle(
                color: AppColors
                    .textSecondary,
                fontSize: 10.5,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        ...items.map(
              (
              _CheckoutCartItem item,
              ) {
            return Padding(
              padding:
              const EdgeInsets.only(
                bottom: 11,
              ),
              child: CheckoutItemsSection(
                child: _CheckoutItemCard(
                item: item,
                onTap: () {
                  _go(
                    AppRoutes
                        .productDetails,
                    arguments: <
                        String,
                        dynamic>{
                      'productId':
                      item.productId,
                      'shoppingMode':
                      item.shoppingMode,
                    },
                  );
                },
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 15),

        _buildCouponCard(
          totals.subtotal,
        ),

        const SizedBox(height: 18),

        const _SafeCheckoutCard(),
      ],
    );

    final Widget summary =
    CheckoutPriceBreakdown(
      child: _PriceSummaryCard(
        totals: totals,
        couponCode: _couponCode,
        shoppingMode: widget.shoppingMode,
        onContinue: () => _continueToPayment(items),
        loading: _continuing,
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        desktop ? 32 : 16,
        18,
        desktop ? 32 : 16,
        110,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(
            maxWidth: 1250,
          ),
          child: desktop
              ? Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 7,
                child:
                mainContent,
              ),
              const SizedBox(
                width: 24,
              ),
              Expanded(
                flex: 3,
                child: summary,
              ),
            ],
          )
              : Column(
            children: <Widget>[
              mainContent,
              const SizedBox(
                height: 22,
              ),
              summary,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    final bool shop =
        widget.shoppingMode == 'shop';

    return Container(
      width: double.infinity,
      constraints:
      const BoxConstraints(
        minHeight: 175,
      ),
      padding:
      const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: shop
              ? const <Color>[
            Color(0xFF153B2C),
            Color(0xFF35865F),
          ]
              : const <Color>[
            Color(0xFF043D22),
            Color(0xFF17A45B),
          ],
        ),
        borderRadius:
        BorderRadius.circular(28),
        boxShadow:
        const <BoxShadow>[
          BoxShadow(
            color:
            Color(0x1D0B7A3E),
            blurRadius: 26,
            offset:
            Offset(0, 11),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 180,
              height: 180,
              decoration:
              const BoxDecoration(
                color:
                Color(0x10FFFFFF),
                shape:
                BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: -8,
            child: Icon(
              shop
                  ? Icons
                  .storefront_rounded
                  : Icons
                  .shopping_basket_rounded,
              size: 105,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 540,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration:
                  BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius:
                    BorderRadius
                        .circular(30),
                  ),
                  child: const Text(
                    'FINAL REVIEW',
                    style:
                    TextStyle(
                      color:
                      Colors.white,
                      fontSize: 8.5,
                      letterSpacing:
                      0.7,
                      fontWeight:
                      FontWeight
                          .w900,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                Text(
                  shop
                      ? 'Review your business order'
                      : 'Almost ready for fresh delivery',
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 26,
                    height: 1.1,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 9,
                ),
                const Text(
                  'Confirm products, delivery details and address before proceeding to payment.',
                  style: TextStyle(
                    color:
                    Colors.white70,
                    fontSize: 11.5,
                    height: 1.5,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return const Row(
      children: <Widget>[
        Expanded(
          child: _CheckoutStep(
            number: '1',
            label: 'Cart',
            complete: true,
          ),
        ),
        _StepLine(
          complete: true,
        ),
        Expanded(
          child: _CheckoutStep(
            number: '2',
            label: 'Delivery',
            complete: true,
          ),
        ),
        _StepLine(
          complete: true,
        ),
        Expanded(
          child: _CheckoutStep(
            number: '3',
            label: 'Address',
            complete: true,
          ),
        ),
        _StepLine(
          complete: false,
        ),
        Expanded(
          child: _CheckoutStep(
            number: '4',
            label: 'Payment',
            complete: false,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard() {
    final String label =
    _stringValue(
      widget.address['label'],
      fallback: 'Delivery Address',
    );

    final String name =
    _stringValue(
      widget.address['fullName'],
    );

    final String phone =
    _stringValue(
      widget.address['phone'],
    );

    String address =
    _stringValue(
      widget.address[
      'displayAddress'],
    );

    if (address.isEmpty) {
      final List<String> parts =
      <String>[
        _stringValue(
          widget.address['house'],
        ),
        _stringValue(
          widget.address['area'],
        ),
        _stringValue(
          widget.address[
          'landmark'],
        ),
        _stringValue(
          widget.address['city'],
        ),
        _stringValue(
          widget.address['state'],
        ),
        _stringValue(
          widget.address['pincode'],
        ),
      ];

      address = parts
          .where(
            (
            String item,
            ) =>
        item.isNotEmpty,
      )
          .join(', ');
    }

    return CheckoutAddressSection(
      child: _ReviewCard(
      icon:
      Icons.location_on_rounded,
      title: 'Delivery Address',
      action: 'CHANGE',
      onAction: () {
        Navigator.of(context).pop();
      },
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
              const Color(0xFFEAF7EF),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              _addressIcon(label),
              color:
              AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style:
                  const TextStyle(
                    color: AppColors
                        .textPrimary,
                    fontSize: 12.5,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                if (name.isNotEmpty) ...<
                    Widget>[
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    name,
                    style:
                    const TextStyle(
                      color: AppColors
                          .textPrimary,
                      fontSize: 10.5,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(
                  height: 4,
                ),
                Text(
                  address.isEmpty
                      ? 'No address information'
                      : address,
                  style:
                  const TextStyle(
                    color: AppColors
                        .textSecondary,
                    fontSize: 10.5,
                    height: 1.45,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                if (phone.isNotEmpty) ...<
                    Widget>[
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    phone,
                    style:
                    const TextStyle(
                      color: AppColors
                          .textSecondary,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return CheckoutDeliverySection(
      child: _ReviewCard(
      icon:
      Icons.local_shipping_rounded,
      title: 'Delivery Details',
      action: 'CHANGE',
      onAction: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
      child: Column(
        children: <Widget>[
          _DetailRow(
            label: 'Method',
            value:
            _deliveryMethodText(
              widget.deliveryMethod,
            ),
          ),
          if (widget.deliveryDate !=
              null &&
              widget.deliveryDate!
                  .isNotEmpty) ...<
              Widget>[
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Date',
              value:
              _formatDate(
                widget.deliveryDate!,
              ),
            ),
          ],
          const SizedBox(height: 10),
          _DetailRow(
            label: 'Time',
            value: _slotText(
              widget.deliverySlot,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCouponCard(
      double subtotal,
      ) {
    return CheckoutCouponSection(
      child: Container(
      padding:
      const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient:
        const LinearGradient(
          colors: <Color>[
            Color(0xFFFFF8E8),
            Color(0xFFFFFCF7),
          ],
        ),
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color:
          const Color(0xFFF0DDAF),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor:
                Color(0xFFFFEAB7),
                child: Icon(
                  Icons
                      .local_offer_rounded,
                  color:
                  Color(0xFFA86F08),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: <Widget>[
                    Text(
                      'Apply Coupon',
                      style:
                      TextStyle(
                        color: AppColors
                            .textPrimary,
                        fontSize: 13.5,
                        fontWeight:
                        FontWeight
                            .w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Save more on your order',
                      style:
                      TextStyle(
                        color: AppColors
                            .textSecondary,
                        fontSize: 10,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (_couponCode != null)
            Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              decoration:
              BoxDecoration(
                color:
                Colors.white,
                borderRadius:
                BorderRadius
                    .circular(14),
                border: Border.all(
                  color:
                  AppColors.success,
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons
                        .check_circle_rounded,
                    color:
                    AppColors.success,
                  ),
                  const SizedBox(
                    width: 9,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: <Widget>[
                        Text(
                          _couponCode!,
                          style:
                          const TextStyle(
                            color: AppColors
                                .textPrimary,
                            fontSize: 11.5,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),
                        Text(
                          'You save ${_currency(_couponDiscount)}',
                          style:
                          const TextStyle(
                            color: AppColors
                                .success,
                            fontSize: 9.5,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed:
                    _removeCoupon,
                    child:
                    const Text(
                      'REMOVE',
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: <Widget>[
                Expanded(
                  child:
                  TextField(
                    controller:
                    _couponController,
                    textCapitalization:
                    TextCapitalization
                        .characters,
                    decoration:
                    const InputDecoration(
                      hintText:
                      'Enter coupon code',
                      prefixIcon:
                      Icon(
                        Icons
                            .discount_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 9,
                ),
                SizedBox(
                  height: 52,
                  child:
                  FilledButton(
                    onPressed:
                    _applyingCoupon
                        ? null
                        : () {
                      _applyCoupon();
                    },
                    child:
                    _applyingCoupon
                        ? const SizedBox(
                      width:
                      17,
                      height:
                      17,
                      child:
                      CircularProgressIndicator(
                        color: Colors
                            .white,
                        strokeWidth:
                        2,
                      ),
                    )
                        : const Text(
                      'APPLY',
                      style:
                      TextStyle(
                        fontWeight:
                        FontWeight
                            .w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      ),
    );
  }
}

class _CheckoutItemCard
    extends StatelessWidget {
  const _CheckoutItemCard({
    required this.item,
    required this.onTap,
  });

  final _CheckoutCartItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(21),
        child: Container(
          padding:
          const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              21,
            ),
            border: Border.all(
              color: item.inStock
                  ? AppColors.border
                  : AppColors.error,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 83,
                height: 83,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFF3F8F5,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(15),
                ),
                child:
                _ProductImage(
                  image: item.image,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: <Widget>[
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        color: AppColors
                            .textPrimary,
                        fontSize: 12.5,
                        height: 1.25,
                        fontWeight:
                        FontWeight
                            .w900,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${item.unit} • Qty ${item.quantity}',
                      style:
                      const TextStyle(
                        color: AppColors
                            .textSecondary,
                        fontSize: 9.5,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          _currency(
                            item.total,
                          ),
                          style:
                          const TextStyle(
                            color: AppColors
                                .textPrimary,
                            fontSize: 13,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),
                        if (item.totalMrp >
                            item.total) ...<
                            Widget>[
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            _currency(
                              item.totalMrp,
                            ),
                            style:
                            const TextStyle(
                              color: AppColors
                                  .textSecondary,
                              fontSize:
                              9.5,
                              decoration:
                              TextDecoration
                                  .lineThrough,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (!item.inStock)
                          const Text(
                            'OUT OF STOCK',
                            style:
                            TextStyle(
                              color: AppColors
                                  .error,
                              fontSize: 8,
                              fontWeight:
                              FontWeight
                                  .w900,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.action,
    required this.onAction,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String action;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFEAF7EF,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(11),
                ),
                child: Icon(
                  icon,
                  color:
                  AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style:
                  const TextStyle(
                    color: AppColors
                        .textPrimary,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: onAction,
                child: Text(
                  action,
                  style:
                  const TextStyle(
                    fontSize: 9,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _PriceSummaryCard
    extends StatelessWidget {
  const _PriceSummaryCard({
    required this.totals,
    required this.couponCode,
    required this.shoppingMode,
    required this.onContinue,
    required this.loading,
  });

  final _CheckoutTotals totals;
  final String? couponCode;
  final String shoppingMode;
  final VoidCallback onContinue;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow:
        const <BoxShadow>[
          BoxShadow(
            color:
            Color(0x09000000),
            blurRadius: 20,
            offset:
            Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Price Details',
            style: TextStyle(
              color:
              AppColors.textPrimary,
              fontSize: 18,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _PriceRow(
            label: 'Item total',
            value: _currency(
              totals.mrpTotal,
            ),
          ),
          if (totals.productSavings >
              0) ...<Widget>[
            const SizedBox(height: 11),
            _PriceRow(
              label:
              'Product discount',
              value:
              '- ${_currency(totals.productSavings)}',
              color:
              AppColors.success,
            ),
          ],
          if (totals.couponDiscount >
              0) ...<Widget>[
            const SizedBox(height: 11),
            _PriceRow(
              label: couponCode == null
                  ? 'Coupon discount'
                  : 'Coupon ($couponCode)',
              value:
              '- ${_currency(totals.couponDiscount)}',
              color:
              AppColors.success,
            ),
          ],
          const SizedBox(height: 11),
          _PriceRow(
            label: 'Delivery fee',
            value:
            totals.deliveryFee <= 0
                ? 'FREE'
                : _currency(
              totals
                  .deliveryFee,
            ),
            color:
            totals.deliveryFee <=
                0
                ? AppColors.success
                : null,
          ),
          const Padding(
            padding:
            EdgeInsets.symmetric(
              vertical: 15,
            ),
            child: Divider(),
          ),
          _PriceRow(
            label: 'Total Amount',
            value: _currency(
              totals.grandTotal,
            ),
            bold: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding:
            const EdgeInsets.all(
              12,
            ),
            decoration:
            BoxDecoration(
              color:
              const Color(
                0xFFEAF7EF,
              ),
              borderRadius:
              BorderRadius
                  .circular(14),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons
                      .verified_user_outlined,
                  color:
                  AppColors.primary,
                  size: 20,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    shoppingMode ==
                        'shop'
                        ? 'Bulk order securely prepared for payment.'
                        : 'Your fresh order is ready for secure payment.',
                    style:
                    const TextStyle(
                      color: AppColors
                          .primary,
                      fontSize: 9.5,
                      height: 1.35,
                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ContinuePaymentBar(onPressed: onContinue, loading: loading),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop();
            },
            child: const Text(
              'BACK TO ADDRESS',
              style: TextStyle(
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeCheckoutCard
    extends StatelessWidget {
  const _SafeCheckoutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        const Color(0xFFEAF7EF),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: const Row(
        children: <Widget>[
          CircleAvatar(
            radius: 23,
            backgroundColor:
            Colors.white,
            child: Icon(
              Icons
                  .shield_outlined,
              color:
              AppColors.primary,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Secure checkout',
                  style: TextStyle(
                    color:
                    AppColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your delivery and payment information is handled securely.',
                  style: TextStyle(
                    color: AppColors
                        .textSecondary,
                    fontSize: 9.5,
                    height: 1.4,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutStep
    extends StatelessWidget {
  const _CheckoutStep({
    required this.number,
    required this.label,
    required this.complete,
  });

  final String number;
  final String label;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          alignment:
          Alignment.center,
          decoration: BoxDecoration(
            color: complete
                ? AppColors.primary
                : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: complete
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          child: complete
              ? const Icon(
            Icons
                .check_rounded,
            color:
            Colors.white,
            size: 17,
          )
              : Text(
            number,
            style:
            const TextStyle(
              color: AppColors
                  .textSecondary,
              fontSize: 10,
              fontWeight:
              FontWeight
                  .w900,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: complete
                ? AppColors.primary
                : AppColors
                .textSecondary,
            fontSize: 8.5,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StepLine
    extends StatelessWidget {
  const _StepLine({
    required this.complete,
  });

  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin:
        const EdgeInsets.only(
          left: 3,
          right: 3,
          bottom: 19,
        ),
        color: complete
            ? AppColors.primary
            : AppColors.border,
      ),
    );
  }
}

class _DetailRow
    extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style:
            const TextStyle(
              color: AppColors
                  .textSecondary,
              fontSize: 10.5,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign:
            TextAlign.right,
            style:
            const TextStyle(
              color:
              AppColors.textPrimary,
              fontSize: 10.5,
              fontWeight:
              FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceRow
    extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold
                  ? AppColors
                  .textPrimary
                  : AppColors
                  .textSecondary,
              fontSize:
              bold ? 13 : 10.5,
              fontWeight: bold
                  ? FontWeight.w900
                  : FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ??
                AppColors.textPrimary,
            fontSize:
            bold ? 17 : 11,
            fontWeight: bold
                ? FontWeight.w900
                : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ProductImage
    extends StatelessWidget {
  const _ProductImage({
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    if (image.trim().isEmpty) {
      return const Center(
        child: Icon(
          Icons.eco_rounded,
          color: AppColors.primary,
          size: 42,
        ),
      );
    }

    if (image.startsWith(
      'http://',
    ) ||
        image.startsWith(
          'https://',
        )) {
      return Image.network(
        image,
        fit: BoxFit.contain,
        errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
            ) {
          return const Center(
            child: Icon(
              Icons.eco_rounded,
              color:
              AppColors.primary,
              size: 42,
            ),
          );
        },
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
          ) {
        return const Center(
          child: Icon(
            Icons.eco_rounded,
            color:
            AppColors.primary,
            size: 42,
          ),
        );
      },
    );
  }
}

class _ErrorView
    extends StatelessWidget {
  const _ErrorView({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(28),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons
                  .cloud_off_outlined,
              color: AppColors.error,
              size: 52,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load checkout',
              style: TextStyle(
                color:
                AppColors.textPrimary,
                fontSize: 18,
                fontWeight:
                FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child:
              const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCheckout
    extends StatelessWidget {
  const _EmptyCheckout({
    required this.onShop,
  });

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(28),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons
                  .shopping_basket_outlined,
              color:
              AppColors.primary,
              size: 60,
            ),
            const SizedBox(height: 18),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color:
                AppColors.textPrimary,
                fontSize: 20,
                fontWeight:
                FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onShop,
              child: const Text(
                'START SHOPPING',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginRequired
    extends StatelessWidget {
  const _LoginRequired({
    required this.onLogin,
  });

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,
      body: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(28),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons
                    .lock_outline_rounded,
                color:
                AppColors.primary,
                size: 55,
              ),
              const SizedBox(height: 17),
              const Text(
                'Login to continue checkout',
                style: TextStyle(
                  color: AppColors
                      .textPrimary,
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onLogin,
                child:
                const Text('LOGIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutCartItem {
  const _CheckoutCartItem({
    required this.documentId,
    required this.productId,
    required this.name,
    required this.image,
    required this.shoppingMode,
    required this.unit,
    required this.unitPrice,
    required this.mrp,
    required this.quantity,
    required this.inStock,
  });

  final String documentId;
  final String productId;
  final String name;
  final String image;
  final String shoppingMode;
  final String unit;

  final double unitPrice;
  final double mrp;

  final int quantity;
  final bool inStock;

  double get total =>
      unitPrice * quantity;

  double get totalMrp =>
      mrp * quantity;

  factory _CheckoutCartItem.fromMap(Map<String, dynamic> data) {

    final double price =
    _toDouble(
      data['unitPrice'] ??
          data['price'],
    );

    final double mrp =
    _toDouble(
      data['mrp'],
      fallback: price,
    );

    return _CheckoutCartItem(
      documentId: _stringValue(data['id'] ?? data['cartItemId']),
      productId:
      _stringValue(
        data['productId'],
      ),
      name:
      _stringValue(
        data['name'],
        fallback:
        'Fresh Product',
      ),
      image:
      _stringValue(
        data['imageUrl'] ??
            data['image'],
      ),
      shoppingMode:
      _stringValue(
        data[
        'shoppingMode'],
        fallback: 'home',
      ) ==
          'shop'
          ? 'shop'
          : 'home',
      unit:
      _stringValue(
        data['unit'],
        fallback: '1 unit',
      ),
      unitPrice: price,
      mrp: mrp,
      quantity:
      _toInt(
        data['quantity'],
        fallback: 1,
      ),
      inStock:
      data['inStock'] is bool
          ? data['inStock']
      as bool
          : true,
    );
  }
}

class _CheckoutTotals {
  const _CheckoutTotals({
    required this.subtotal,
    required this.mrpTotal,
    required this.productSavings,
    required this.couponDiscount,
    required this.deliveryFee,
    required this.grandTotal,
    required this.quantity,
  });

  final double subtotal;
  final double mrpTotal;
  final double productSavings;
  final double couponDiscount;
  final double deliveryFee;
  final double grandTotal;

  final int quantity;

  factory _CheckoutTotals.fromItems(
      List<_CheckoutCartItem> items, {
        required double couponDiscount,
      }) {
    double subtotal = 0;
    double mrpTotal = 0;
    int quantity = 0;

    for (final _CheckoutCartItem item in items) {
      subtotal += item.total;
      mrpTotal += item.totalMrp;
      quantity += item.quantity;
    }

    if (mrpTotal < subtotal) {
      mrpTotal = subtotal;
    }

    final double productSavings =
        mrpTotal - subtotal;

    final double safeCoupon =
    couponDiscount < 0
        ? 0
        : couponDiscount >
        subtotal
        ? subtotal
        : couponDiscount;

    const double deliveryFee = 0;

    final double grandTotal =
        subtotal -
            safeCoupon +
            deliveryFee;

    return _CheckoutTotals(
      subtotal: subtotal,
      mrpTotal: mrpTotal,
      productSavings:
      productSavings,
      couponDiscount:
      safeCoupon,
      deliveryFee:
      deliveryFee,
      grandTotal:
      grandTotal < 0
          ? 0
          : grandTotal,
      quantity: quantity,
    );
  }
}

IconData _addressIcon(
    String label,
    ) {
  switch (label.toLowerCase()) {
    case 'work':
      return Icons
          .work_outline_rounded;

    case 'shop':
      return Icons
          .storefront_rounded;

    case 'other':
      return Icons
          .location_on_outlined;

    default:
      return Icons.home_rounded;
  }
}

String _deliveryMethodText(
    String value,
    ) {
  switch (value) {
    case 'scheduled':
      return 'Scheduled Delivery';

    case 'preorder':
      return 'Pre-Order';

    default:
      return 'Quick Delivery';
  }
}

String _slotText(
    String value,
    ) {
  switch (value) {
    case 'morning':
      return '8:00 AM - 11:00 AM';

    case 'afternoon':
      return '12:00 PM - 3:00 PM';

    case 'evening':
      return '4:00 PM - 7:00 PM';

    case 'night':
      return '7:00 PM - 9:00 PM';

    default:
      return value;
  }
}

String _formatDate(
    String value,
    ) {
  final DateTime? date =
  DateTime.tryParse(value);

  if (date == null) {
    return value;
  }

  const List<String> months =
  <String>[
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _stringValue(
    dynamic value, {
      String fallback = '',
    }) {
  if (value == null) {
    return fallback;
  }

  final String result =
  value.toString().trim();

  return result.isEmpty
      ? fallback
      : result;
}

double _toDouble(
    dynamic value, {
      double fallback = 0,
    }) {
  if (value == null) {
    return fallback;
  }

  if (value is num) {
    return value.toDouble();
  }

  final String cleaned =
  value
      .toString()
      .replaceAll(',', '')
      .replaceAll(
    RegExp(
      r'[^0-9.\-]',
    ),
    '',
  );

  return double.tryParse(
    cleaned,
  ) ??
      fallback;
}

int _toInt(
    dynamic value, {
      int fallback = 0,
    }) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
    value?.toString() ??
        '',
  ) ??
      fallback;
}

String _currency(
    double value,
    ) {
  if (value ==
      value.roundToDouble()) {
    return '₹${value.toStringAsFixed(0)}';
  }

  return '₹${value.toStringAsFixed(2)}';
}
