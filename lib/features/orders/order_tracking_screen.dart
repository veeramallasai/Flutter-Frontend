import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'widgets/order_status_tracker.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, this.orderId = '', this.initialOrder});

  final String orderId;
  final OrderModel? initialOrder;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late final OrderRepository _repository;

  Stream<OrderModel?>? _orderStream;
  OrderModel? _initialOrder;
  String _orderId = '';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _repository = OrderRepository();
    _initialOrder = widget.initialOrder;
    _orderId = widget.orderId.trim();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;
    _readRouteArguments();

    if (_orderId.isNotEmpty) {
      _orderStream = _repository.watchOrder(_orderId);
    }
  }

  void _readRouteArguments() {
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is OrderModel) {
      _initialOrder = arguments;
      _orderId = arguments.id;
      return;
    }

    if (arguments is String && arguments.trim().isNotEmpty) {
      _orderId = arguments.trim();
      return;
    }

    if (arguments is Map) {
      final Object? orderValue = arguments['order'];

      if (orderValue is OrderModel) {
        _initialOrder = orderValue;
        _orderId = orderValue.id;
      }

      final String argumentOrderId =
          (arguments['orderId'] ?? arguments['id'] ?? '').toString().trim();

      if (argumentOrderId.isNotEmpty) {
        _orderId = argumentOrderId;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildHeader(),
            Expanded(
              child:
                  _orderStream == null
                      ? _buildWithoutStream()
                      : StreamBuilder<OrderModel?>(
                        stream: _orderStream,
                        initialData: _initialOrder,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<OrderModel?> snapshot,
                        ) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              snapshot.data == null) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return _buildErrorState(
                              _friendlyError(snapshot.error),
                            );
                          }

                          final OrderModel? order = snapshot.data;

                          if (order == null) {
                            return _buildErrorState('Order not found.');
                          }

                          return _buildContent(order);
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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 9),
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
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 4),
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.location_searching_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Track Order',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Live delivery status updates',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.wifi_tethering_rounded,
            color: AppColors.primary,
            size: 21,
          ),
        ],
      ),
    );
  }

  Widget _buildWithoutStream() {
    if (_initialOrder != null) {
      return _buildContent(_initialOrder!);
    }

    return _buildErrorState('Order ID is missing.');
  }

  Widget _buildContent(OrderModel order) {
    final bool desktop = MediaQuery.sizeOf(context).width >= 900;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        desktop ? 32 : 16,
        20,
        desktop ? 32 : 16,
        32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            children: <Widget>[
              _buildHero(order),
              const SizedBox(height: 18),
              desktop
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 6, child: _buildTimelineCard(order)),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: <Widget>[
                            _buildDeliveryCard(order),
                            const SizedBox(height: 16),
                            _buildAddressCard(order),
                            const SizedBox(height: 16),
                            _buildHelpCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                  : Column(
                    children: <Widget>[
                      _buildTimelineCard(order),
                      const SizedBox(height: 16),
                      _buildDeliveryCard(order),
                      const SizedBox(height: 16),
                      _buildAddressCard(order),
                      const SizedBox(height: 16),
                      _buildHelpCard(),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x2117A45B),
            blurRadius: 25,
            offset: Offset(0, 11),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon(order.status),
              color: AppColors.primary,
              size: 39,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  order.statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _statusMessage(order.status),
                  style: const TextStyle(
                    color: Color(0xFFE8F5E9),
                    fontSize: 10.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'ORDER #${order.shortOrderId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(OrderModel order) {
    return _sectionCard(
      icon: Icons.timeline_rounded,
      title: 'Order Journey',
      child: OrderStatusTracker(order: order),
    );
  }

  Widget _buildDeliveryCard(OrderModel order) {
    return _sectionCard(
      icon: Icons.schedule_rounded,
      title: 'Delivery Schedule',
      child: Column(
        children: <Widget>[
          _detailRow('Method', order.deliveryMethodLabel),
          if (order.deliveryDate != null)
            _detailRow('Date', order.deliveryDate!),
          _detailRow('Time slot', order.deliverySlot),
          _detailRow(
            'Items',
            '${order.calculatedItemCount} '
                '${order.calculatedItemCount == 1 ? 'item' : 'items'}',
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(OrderModel order) {
    final Map<String, dynamic> address = order.address;

    return _sectionCard(
      icon: Icons.location_on_rounded,
      title: 'Delivery Address',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _text(
              address['fullName'] ?? address['name'],
              fallback: 'Delivering to',
            ),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _formatAddress(address),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD98E)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.support_agent_rounded, color: Color(0xFFB87900), size: 27),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Need help with this order?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Contact support from the Profile section.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to track order',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('GO BACK'),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'confirmed':
      return Icons.verified_rounded;
    case 'processing':
    case 'packed':
      return Icons.inventory_2_rounded;
    case 'shipped':
      return Icons.local_shipping_rounded;
    case 'out_for_delivery':
      return Icons.delivery_dining_rounded;
    case 'delivered':
      return Icons.check_circle_rounded;
    case 'cancelled':
    case 'failed':
      return Icons.cancel_rounded;
    case 'placed':
    default:
      return Icons.schedule_rounded;
  }
}

String _statusMessage(String status) {
  switch (status) {
    case 'confirmed':
      return 'Your products are reserved.';
    case 'processing':
    case 'packed':
      return 'Fresh products are being prepared.';
    case 'shipped':
      return 'Your order has started its journey.';
    case 'out_for_delivery':
      return 'Your delivery partner is on the way.';
    case 'delivered':
      return 'Your order was delivered successfully.';
    case 'cancelled':
      return 'This order was cancelled.';
    case 'failed':
      return 'This order could not be completed.';
    case 'placed':
    default:
      return 'We received your order.';
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

  if (parts.isNotEmpty) {
    return parts.join(', ');
  }

  return _text(
    address['fullAddress'] ?? address['address'],
    fallback: 'Address details unavailable',
  );
}

String _text(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }

  final String text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String _friendlyError(Object? error) {
  final String message = error?.toString().trim() ?? '';

  if (message.startsWith('Bad state: ')) {
    return message.substring('Bad state: '.length);
  }

  return message.isEmpty ? 'Please try again.' : message;
}
