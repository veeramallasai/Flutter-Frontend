import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/order_repository.dart';
import 'order_tracking_screen.dart';
import 'widgets/delivery_status_timeline.dart';
import 'widgets/order_item_tile.dart';
import 'widgets/order_price_summary.dart';
import 'widgets/reorder_button.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({
    super.key,
    this.orderId = '',
    this.initialOrder,
    this.onTrack,
  });

  final String orderId;
  final OrderModel? initialOrder;
  final ValueChanged<OrderModel>? onTrack;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late final OrderRepository _repository;
  late final ReviewRepository _reviewRepository;

  Stream<OrderModel?>? _orderStream;
  OrderModel? _initialOrder;
  String _orderId = '';
  bool _initialized = false;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _repository = OrderRepository();
    _reviewRepository = ReviewRepository();
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
      final Map<dynamic, dynamic> map = arguments;
      final Object? orderValue = map['order'];

      if (orderValue is OrderModel) {
        _initialOrder = orderValue;
        _orderId = orderValue.id;
      }

      final String argumentOrderId = (map['orderId'] ?? map['id'] ?? '')
          .toString()
          .trim();

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
              child: _orderStream == null
                  ? _buildWithoutStream()
                  : StreamBuilder<OrderModel?>(
                      stream: _orderStream,
                      initialData: _initialOrder,
                      builder:
                          (
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

                            return _buildOrderContent(order);
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
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Order Details',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Items, delivery and payment information',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
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

  Widget _buildWithoutStream() {
    if (_initialOrder != null) {
      return _buildOrderContent(_initialOrder!);
    }

    return _buildErrorState('Order ID is missing.');
  }

  Widget _buildOrderContent(OrderModel order) {
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
          constraints: const BoxConstraints(maxWidth: 1060),
          child: Column(
            children: <Widget>[
              _buildStatusCard(order),
              const SizedBox(height: 14),
              _buildTimelineCard(order),
              const SizedBox(height: 18),
              desktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: <Widget>[
                              _buildItemsCard(order),
                              if (order.isDelivered) ...<Widget>[
                                const SizedBox(height: 16),
                                _buildReviewSection(order),
                              ],
                              const SizedBox(height: 16),
                              _buildDeliveryCard(order),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: <Widget>[
                              _buildPriceCard(order),
                              const SizedBox(height: 16),
                              _buildPaymentCard(order),
                              const SizedBox(height: 16),
                              _buildAddressCard(order),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        _buildItemsCard(order),
                        if (order.isDelivered) ...<Widget>[
                          const SizedBox(height: 16),
                          _buildReviewSection(order),
                        ],
                        const SizedBox(height: 16),
                        _buildPriceCard(order),
                        const SizedBox(height: 16),
                        _buildDeliveryCard(order),
                        const SizedBox(height: 16),
                        _buildPaymentCard(order),
                        const SizedBox(height: 16),
                        _buildAddressCard(order),
                      ],
                    ),
              const SizedBox(height: 22),
              _buildActions(order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(OrderModel order) {
    final _StatusStyle style = _statusStyle(order.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF043D22), Color(0xFF17A45B)],
        ),
        borderRadius: BorderRadius.circular(25),
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
            width: 66,
            height: 66,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, color: AppColors.primary, size: 36),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _statusMessage(order.status),
                  style: const TextStyle(
                    color: Color(0xFFDDF4E7),
                    fontSize: 10.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
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
          const SizedBox(width: 10),
          Text(
            _formatDate(order.createdAt),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFFDDF4E7),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: DeliveryStatusTimeline(order: order),
    );
  }

  Widget _buildItemsCard(OrderModel order) {
    return _sectionCard(
      icon: Icons.shopping_basket_rounded,
      title: 'Order Items',
      trailing: '${order.calculatedItemCount} items',
      child: order.items.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  'Item details are unavailable.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : Column(
              children: <Widget>[
                for (int index = 0; index < order.items.length; index++)
                  OrderItemTile(
                    item: order.items[index],
                    showDivider: index < order.items.length - 1,
                  ),
              ],
            ),
    );
  }


  Widget _buildReviewSection(OrderModel order) {
    return _sectionCard(
      icon: Icons.rate_review_rounded,
      title: 'Rate Your Order',
      trailing: 'Delivered',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Share your experience with the products you received.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          for (int index = 0; index < order.items.length; index++) ...<Widget>[
            _buildProductReviewTile(order, index),
            if (index < order.items.length - 1)
              const Divider(height: 22, color: AppColors.border),
          ],
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFEAF7EF), Color(0xFFFFFBEC)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCDE5D7)),
            ),
            child: _buildDeliveryPartnerReview(order),
          ),
        ],
      ),
    );
  }

  Widget _buildProductReviewTile(OrderModel order, int index) {
    final Map<String, dynamic> item = order.items[index].toMap();
    final String productName = _text(
      item['productName'] ?? item['name'] ?? item['title'],
      fallback: 'Product ${index + 1}',
    );
    final String productId = _text(
      item['productId'] ?? item['id'],
    );

    return Row(
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.eco_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Verified purchase • Rate this product',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: productId.isEmpty
              ? null
              : () => _openProductReviewDialog(
                    order: order,
                    productId: productId,
                    productName: productName,
                  ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.star_rounded, size: 16),
          label: const Text(
            'RATE',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryPartnerReview(OrderModel order) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _reviewRepository.getDeliveryPartner(order.id),
      builder: (
        BuildContext context,
        AsyncSnapshot<Map<String, dynamic>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: <Widget>[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Loading delivery partner...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        }

        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return const Row(
            children: <Widget>[
              Icon(
                Icons.delivery_dining_rounded,
                color: AppColors.textSecondary,
                size: 24,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Delivery partner details are not assigned to this order yet.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        }

        final Map<String, dynamic> partner = snapshot.data!;
        final String partnerName =
            _text(partner['name'], fallback: 'Delivery Partner');
        final String vehicle = _text(partner['vehicleNumber']);
        final double rating =
            double.tryParse('${partner['rating'] ?? 0}') ?? 0;

        return Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delivery_dining_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    partnerName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    vehicle.isEmpty
                        ? 'Delivery partner'
                        : '$vehicle • ${rating.toStringAsFixed(1)} ★',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _openDeliveryPartnerReviewDialog(
                order: order,
                partnerName: partnerName,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.star_rounded, size: 16),
              label: const Text(
                'RATE',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openProductReviewDialog({
    required OrderModel order,
    required String productId,
    required String productName,
  }) async {
    final TextEditingController commentController = TextEditingController();
    double rating = 5;
    bool saving = false;

    final bool? submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: !saving,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setDialogState,
          ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                'Rate $productName',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'How was the quality of this product?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ratingPicker(
                      rating: rating,
                      onChanged: (double value) {
                        setDialogState(() => rating = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      maxLength: 1500,
                      decoration: InputDecoration(
                        hintText: 'Write your review (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed:
                      saving ? null : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setDialogState(() => saving = true);
                          try {
                            final User? user = FirebaseAuth.instance.currentUser;
                            final String userName = _reviewUserName(user);
                            await _reviewRepository.saveReview(
                              ReviewModel(
                                id: '',
                                productId: productId,
                                userId: user?.uid ?? '',
                                userName: userName,
                                rating: rating,
                                comment: commentController.text.trim(),
                                isVerifiedPurchase: true,
                              ),
                            );
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop(true);
                            }
                          } catch (error) {
                            setDialogState(() => saving = false);
                            if (mounted) {
                              _showMessage(
                                _friendlyError(error),
                                error: true,
                              );
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('SUBMIT REVIEW'),
                ),
              ],
            );
          },
        );
      },
    );

    commentController.dispose();

    if (submitted == true && mounted) {
      _showMessage('Product review submitted successfully.');
      setState(() {});
    }
  }

  Future<void> _openDeliveryPartnerReviewDialog({
    required OrderModel order,
    required String partnerName,
  }) async {
    final TextEditingController commentController = TextEditingController();
    double rating = 5;
    bool saving = false;

    try {
      final Map<String, dynamic> existing =
          await _reviewRepository.getDeliveryPartnerReview(order.id);
      if (existing.isNotEmpty) {
        rating = double.tryParse('${existing['rating'] ?? 5}') ?? 5;
        commentController.text = _text(existing['comment']);
      }
    } catch (_) {
      // A missing previous review is valid for a first-time rating.
    }

    if (!mounted) {
      commentController.dispose();
      return;
    }

    final bool? submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: !saving,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setDialogState,
          ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                'Rate $partnerName',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'How was your delivery experience?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ratingPicker(
                      rating: rating,
                      onChanged: (double value) {
                        setDialogState(() => rating = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      maxLength: 1500,
                      decoration: InputDecoration(
                        hintText: 'Write about the delivery (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed:
                      saving ? null : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setDialogState(() => saving = true);
                          try {
                            await _reviewRepository.saveDeliveryPartnerReview(
                              orderId: order.id,
                              rating: rating,
                              comment: commentController.text,
                            );
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop(true);
                            }
                          } catch (error) {
                            setDialogState(() => saving = false);
                            if (mounted) {
                              _showMessage(
                                _friendlyError(error),
                                error: true,
                              );
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('SUBMIT REVIEW'),
                ),
              ],
            );
          },
        );
      },
    );

    commentController.dispose();

    if (submitted == true && mounted) {
      _showMessage('Delivery partner review submitted successfully.');
      setState(() {});
    }
  }

  Widget _ratingPicker({
    required double rating,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int index = 1; index <= 5; index++)
          IconButton(
            tooltip: '$index star${index == 1 ? '' : 's'}',
            onPressed: () => onChanged(index.toDouble()),
            icon: Icon(
              index <= rating.round()
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: const Color(0xFFFFB000),
              size: 34,
            ),
          ),
      ],
    );
  }

  String _reviewUserName(User? user) {
    final String displayName = user?.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;

    final String email = user?.email?.trim() ?? '';
    if (email.contains('@')) {
      final String name = email.split('@').first.trim();
      if (name.isNotEmpty) return name;
    }

    return 'Verified customer';
  }

  Widget _buildPriceCard(OrderModel order) {
    return OrderPriceSummary(order: order);
  }

  Widget _buildDeliveryCard(OrderModel order) {
    return _sectionCard(
      icon: Icons.local_shipping_rounded,
      title: 'Delivery Details',
      child: Column(
        children: <Widget>[
          _detailRow('Method', order.deliveryMethodLabel),
          if (order.deliveryDate != null)
            _detailRow('Delivery date', order.deliveryDate!),
          _detailRow('Delivery slot', order.deliverySlot),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: <Widget>[
                Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 21,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You will receive updates when the order status changes.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
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

  Widget _buildPaymentCard(OrderModel order) {
    return _sectionCard(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Payment',
      child: Column(
        children: <Widget>[
          _detailRow('Method', order.paymentMethodLabel),
          _detailRow(
            'Status',
            order.paymentStatusLabel,
            valueColor: order.isPaid
                ? AppColors.primary
                : const Color(0xFFE28A00),
          ),
          if (order.transactionId.isNotEmpty)
            _detailRow('Transaction ID', order.transactionId),
          if (order.paymentId.isNotEmpty)
            _detailRow('Payment ID', order.paymentId),
          if (order.isCashOnDelivery &&
              !order.isPaid &&
              !order.isDelivered &&
              !order.isCancelled) ...<Widget>[
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFFE8F7EF), Color(0xFFFFFBEC)],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFCDE5D7)),
              ),
              child: const Row(
                children: <Widget>[
                  Icon(
                    Icons.schedule_send_rounded,
                    color: AppColors.primary,
                    size: 21,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Your COD order stays confirmed. Online payment activates after secure gateway setup.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 9.5,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            FilledButton.icon(
              onPressed: () => _payNow(order),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF073D24),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.lock_rounded, size: 18),
              label: const Text('ONLINE PAYMENT SETUP INFO'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressCard(OrderModel order) {
    final Map<String, dynamic> address = order.address;
    final String name = _text(
      address['fullName'] ?? address['name'],
      fallback: 'Delivery address',
    );
    final String phone = _text(address['phone'] ?? address['phoneNumber']);

    return _sectionCard(
      icon: Icons.location_on_rounded,
      title: 'Delivering To',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (phone.isNotEmpty) ...<Widget>[
            const SizedBox(height: 5),
            Text(
              phone,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 8),
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

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    String? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
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
                  color: const Color(0xFFEAF7EF),
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
              if (trailing != null)
                Text(
                  trailing,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: important
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: important ? 12.5 : 10.5,
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
                fontSize: important ? 17 : 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(OrderModel order) {
    return Column(
      children: <Widget>[
        if (order.canTrack)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                if (widget.onTrack != null) {
                  widget.onTrack!(order);
                } else {
                  _openOrderTracking(order);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.location_searching_rounded),
              label: const Text(
                'TRACK ORDER',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        if (order.canTrack && order.canCancel) const SizedBox(height: 11),
        if (order.canCancel)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _cancelling ? null : () => _cancelOrder(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: _cancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppColors.error,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.close_rounded),
              label: Text(
                _cancelling ? 'CANCELLING...' : 'CANCEL ORDER',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        if ((order.canTrack || order.canCancel) && order.canReorder)
          const SizedBox(height: 11),
        if (order.canReorder)
          SizedBox(
            width: double.infinity,
            child: ReorderButton(
              order: order,
              onReorder: (OrderModel selectedOrder) async {
                await _repository.reorder(selectedOrder.id);
              },
              onSuccess: () {
                _showMessage('Order items added to your cart.');
              },
              onError: (Object error) {
                _showMessage(_friendlyError(error), error: true);
              },
            ),
          ),
      ],
    );
  }

  Future<void> _cancelOrder(OrderModel order) async {
    final TextEditingController controller = TextEditingController();

    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Cancel order?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Order #${order.shortOrderId} will be cancelled.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 17),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  maxLength: 150,
                  decoration: const InputDecoration(
                    hintText: 'Reason (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        child: const Text('KEEP ORDER'),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('CANCEL'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    final String reason = controller.text.trim();
    controller.dispose();

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _cancelling = true);

    try {
      await _repository.cancelOrder(orderId: order.id, reason: reason);
      final OrderModel? updated = await _repository.getOrder(order.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _initialOrder = updated ?? order;
        _orderStream = Stream<OrderModel?>.value(updated ?? order);
      });

      _showMessage('Order cancelled successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(_friendlyError(error), error: true);
    } finally {
      if (mounted) {
        setState(() => _cancelling = false);
      }
    }
  }

  Future<void> _openOrderTracking(OrderModel order) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            OrderTrackingScreen(orderId: order.id, initialOrder: order),
      ),
    );
  }

  Future<void> _payNow(OrderModel order) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        icon: const Icon(Icons.verified_user_rounded, color: AppColors.primary),
        title: const Text('Secure online payment'),
        content: Text(
          'Your COD order for ₹${order.totalAmount.toStringAsFixed(0)} is safe. '
          'UPI and card payment will be enabled after the Razorpay production '
          'account and webhook secret are configured.',
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: SingleChildScrollView(
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
              'Unable to open order',
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

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: error ? AppColors.error : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
}

class _StatusStyle {
  const _StatusStyle({required this.icon});

  final IconData icon;
}

_StatusStyle _statusStyle(String status) {
  switch (status) {
    case 'delivered':
      return const _StatusStyle(icon: Icons.check_circle_rounded);
    case 'cancelled':
    case 'failed':
      return const _StatusStyle(icon: Icons.cancel_rounded);
    case 'shipped':
    case 'out_for_delivery':
      return const _StatusStyle(icon: Icons.local_shipping_rounded);
    case 'processing':
    case 'packed':
      return const _StatusStyle(icon: Icons.inventory_2_rounded);
    case 'confirmed':
      return const _StatusStyle(icon: Icons.verified_rounded);
    case 'placed':
    default:
      return const _StatusStyle(icon: Icons.schedule_rounded);
  }
}

String _statusMessage(String status) {
  switch (status) {
    case 'confirmed':
      return 'Your order has been confirmed.';
    case 'processing':
    case 'packed':
      return 'Your fresh products are being prepared.';
    case 'shipped':
      return 'Your order has been shipped.';
    case 'out_for_delivery':
      return 'Your order is out for delivery.';
    case 'delivered':
      return 'Your order was delivered successfully.';
    case 'cancelled':
      return 'This order was cancelled.';
    case 'failed':
      return 'This order could not be completed.';
    case 'placed':
    default:
      return 'Your order was placed successfully.';
  }
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Recently';
  }

  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${date.day.toString().padLeft(2, '0')} '
      '${months[date.month - 1]} ${date.year}';
}

String _formatAddress(Map<String, dynamic> address) {
  final List<String> parts = <String>[
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
