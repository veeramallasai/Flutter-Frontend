import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'orders_screen.dart';
import 'widgets/order_success_card.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final OrderRepository _repository = OrderRepository();
  Map<String, dynamic> _order = <String, dynamic>{};
  bool _initialized = false;
  bool _loading = true;
  String? _loadMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;

    final Object? routeArguments = ModalRoute.of(context)?.settings.arguments;

    if (routeArguments is Map) {
      _order.addAll(Map<String, dynamic>.from(routeArguments));
    }

    if (widget.arguments != null) {
      _order.addAll(widget.arguments!);
    }

    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final String orderId = _text(_order['orderId']);

    if (orderId.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _loadMessage = 'Order details are not available.';
      });
      return;
    }

    try {
      final OrderModel? order = await _repository.getOrder(orderId);

      if (!mounted) {
        return;
      }

      if (order != null) {
        setState(() {
          _order = <String, dynamic>{
            ..._order,
            ...order.toMap(),
            'orderId': orderId,
          };
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _loadMessage =
              'Order placed successfully. Full details will appear shortly.';
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _loadMessage =
            'Order placed successfully. Unable to refresh details right now.';
      });
    }
  }

  void _continueShopping() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (Route<dynamic> route) => false);
  }

  void _viewOrders() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const OrdersScreen()),
    );
  }

  void _openPayNow() {
    Navigator.pushNamed(
      context,
      AppRoutes.orderDetails,
      arguments: <String, dynamic>{'orderId': _text(_order['orderId'])},
    );
  }

  bool get _isCashOnDelivery {
    return _text(_order['paymentMethod']) == 'cash_on_delivery';
  }

  double get _deliveryPartnerTip => _toDouble(_order['deliveryPartnerTip']);

  double get _displayTotalAmount {
    final double current = _toDouble(_order['totalAmount']);
    final double backend = _toDouble(_order['backendTotalAmount']);
    if (_deliveryPartnerTip <= 0) return current;

    // When full order details are refreshed, older backend builds can return a
    // base total that does not contain the client-side delivery partner tip.
    if (backend > 0 && current <= backend + 0.001) {
      return backend + _deliveryPartnerTip;
    }
    return current;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool desktop = width >= 900;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadOrder,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      desktop ? 32 : 16,
                      22,
                      desktop ? 32 : 16,
                      32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1050),
                        child: Column(
                          children: <Widget>[
                            _buildSuccessCard(),
                            const SizedBox(height: 20),
                            if (_loading) _buildLoadingCard(),
                            if (_loadMessage != null) ...<Widget>[
                              _buildMessageCard(_loadMessage!),
                              const SizedBox(height: 16),
                            ],
                            desktop
                                ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        children: <Widget>[
                                          _buildOrderSummary(),
                                          const SizedBox(height: 16),
                                          _buildDeliveryCard(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        children: <Widget>[
                                          _buildPaymentCard(),
                                          const SizedBox(height: 16),
                                          _buildAddressCard(),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  children: <Widget>[
                                    _buildOrderSummary(),
                                    const SizedBox(height: 16),
                                    _buildDeliveryCard(),
                                    const SizedBox(height: 16),
                                    _buildPaymentCard(),
                                    const SizedBox(height: 16),
                                    _buildAddressCard(),
                                  ],
                                ),
                            const SizedBox(height: 22),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.eco_rounded, color: AppColors.primary, size: 29),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Farm To Home',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Icon(Icons.verified_rounded, color: AppColors.primary, size: 22),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    final String orderId = _text(_order['orderId']);
    final OrderModel order = OrderModel.fromMap(_order, documentId: orderId);

    return OrderSuccessCard(order: order, title: 'Order Confirmed!');
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        children: <Widget>[
          SizedBox(
            width: 23,
            height: 23,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'Loading your latest order details...',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD98E)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return _sectionCard(
      icon: Icons.receipt_long_rounded,
      title: 'Order Summary',
      child: Column(
        children: <Widget>[
          _detailRow(
            'Order number',
            _text(_order['orderNumber'], fallback: 'Processing'),
          ),
          _detailRow(
            'Order status',
            _label(_text(_order['status'], fallback: 'placed')),
            valueColor: AppColors.primary,
          ),
          _detailRow(
            'Shopping mode',
            _text(_order['shoppingMode']) == 'shop'
                ? 'Shop Owner'
                : 'Home Customer',
          ),
          _detailRow('Total items', '${_toInt(_order['itemCount'])}'),
          const Divider(height: 24),
          _detailRow(
            'Grand total',
            _currency(_displayTotalAmount),
            important: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    final String deliveryMethod = _text(
      _order['deliveryMethod'],
      fallback: 'quick',
    );
    final String? deliveryDate = _nullableText(_order['deliveryDate']);

    return _sectionCard(
      icon: Icons.local_shipping_rounded,
      title: 'Delivery Details',
      child: Column(
        children: <Widget>[
          _detailRow('Delivery method', _deliveryLabel(deliveryMethod)),
          if (deliveryDate != null) _detailRow('Delivery date', deliveryDate),
          _detailRow(
            'Delivery slot',
            _text(_order['deliverySlot'], fallback: 'Earliest available'),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: <Widget>[
                Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 21,
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'We will notify you when your order status changes.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final String transactionId = _text(_order['transactionId']);

    return _sectionCard(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Payment',
      child: Column(
        children: <Widget>[
          _detailRow('Method', _paymentLabel(_text(_order['paymentMethod']))),
          _detailRow(
            'Status',
            _paymentStatusLabel(_text(_order['paymentStatus'])),
            valueColor:
                _isCashOnDelivery ? const Color(0xFFE28A00) : AppColors.primary,
          ),
          if (transactionId.isNotEmpty)
            _detailRow('Transaction ID', transactionId),
          if (_deliveryPartnerTip > 0)
            _detailRow(
              'Delivery partner tip',
              _currency(_deliveryPartnerTip),
              valueColor: AppColors.primary,
            ),
          const Divider(height: 24),
          _detailRow(
            _isCashOnDelivery ? 'Amount to pay' : 'Amount paid',
            _currency(_displayTotalAmount),
            important: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    final Map<String, dynamic> address = _mapValue(_order['address']);
    final String fullName = _text(
      address['fullName'] ?? address['name'],
      fallback: 'Delivery address',
    );
    final String phone = _text(address['phone'] ?? address['phoneNumber']);
    final String formattedAddress = _formatAddress(address);

    return _sectionCard(
      icon: Icons.location_on_rounded,
      title: 'Delivering To',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            fullName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (phone.isNotEmpty) ...<Widget>[
            const SizedBox(height: 5),
            Text(
              phone,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            formattedAddress,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0B000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool important = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color:
                    important ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: important ? 13 : 11,
                fontWeight: important ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: important ? 18 : 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: <Widget>[
        if (_isCashOnDelivery &&
            _text(_order['paymentStatus']) != 'paid') ...<Widget>[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _openPayNow,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              icon: const Icon(Icons.lock_rounded),
              label: const Text(
                'PAY ONLINE BEFORE DELIVERY',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 11),
        ],
        SizedBox(
          width: double.infinity,
          height: 55,
          child: FilledButton.icon(
            onPressed: _viewOrders,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text(
              'VIEW MY ORDERS',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.2),
            ),
          ),
        ),
        const SizedBox(height: 11),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _continueShopping,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.shopping_bag_rounded),
            label: const Text(
              'CONTINUE SHOPPING',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.2),
            ),
          ),
        ),
      ],
    );
  }
}

Map<String, dynamic> _mapValue(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}

String _text(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }

  final String text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String? _nullableText(dynamic value) {
  final String text = _text(value);
  return text.isEmpty ? null : text;
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

String _currency(double value) {
  if (value == value.roundToDouble()) {
    return '₹${value.toStringAsFixed(0)}';
  }

  return '₹${value.toStringAsFixed(2)}';
}

String _label(String value) {
  if (value.isEmpty) {
    return 'Placed';
  }

  return value
      .split('_')
      .where((String word) => word.isNotEmpty)
      .map(
        (String word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _paymentLabel(String value) {
  switch (value) {
    case 'cash_on_delivery':
      return 'Cash on Delivery';
    case 'google_pay':
      return 'Google Pay';
    case 'phone_pe':
      return 'PhonePe';
    case 'upi':
      return 'UPI';
    case 'card':
      return 'Credit / Debit Card';
    case 'net_banking':
      return 'Net Banking';
    default:
      return _label(value);
  }
}

String _paymentStatusLabel(String value) {
  switch (value) {
    case 'paid_test':
    case 'paid':
      return 'Paid';
    case 'pending':
      return 'Pay on Delivery';
    case 'failed':
      return 'Failed';
    default:
      return _label(value);
  }
}

String _deliveryLabel(String value) {
  switch (value) {
    case 'quick':
      return 'Quick Delivery';
    case 'scheduled':
      return 'Scheduled Delivery';
    case 'preorder':
    case 'pre_order':
      return 'Pre-order Delivery';
    default:
      return _label(value);
  }
}

String _formatAddress(Map<String, dynamic> address) {
  final List<String> parts =
      <String>[
        _text(address['houseNumber'] ?? address['houseNo']),
        _text(address['building'] ?? address['apartment']),
        _text(address['street'] ?? address['addressLine1']),
        _text(address['landmark']),
        _text(address['area'] ?? address['addressLine2']),
        _text(address['city']),
        _text(address['state']),
        _text(address['pincode'] ?? address['postalCode']),
      ].where((String value) => value.isNotEmpty).toList();

  if (parts.isEmpty) {
    final String fallback = _text(address['fullAddress'] ?? address['address']);
    return fallback.isEmpty ? 'Address details unavailable' : fallback;
  }

  return parts.join(', ');
}
