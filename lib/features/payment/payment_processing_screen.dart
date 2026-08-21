import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';

class PaymentProcessingScreen extends StatefulWidget {
  const PaymentProcessingScreen({
    super.key,
    required this.orderArguments,
    this.processingDuration = const Duration(milliseconds: 1800),
  });

  final Map<String, dynamic> orderArguments;
  final Duration processingDuration;

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  Timer? _navigationTimer;
  bool _navigationStarted = false;

  bool get _isCashOnDelivery {
    return _stringValue(widget.orderArguments['paymentMethod']) ==
        'cash_on_delivery';
  }

  String get _orderNumber {
    return _stringValue(
      widget.orderArguments['orderNumber'],
      fallback: 'Farm To Home Order',
    );
  }

  double get _totalAmount {
    return _toDouble(widget.orderArguments['totalAmount']);
  }

  int get _itemCount {
    return _toInt(widget.orderArguments['itemCount']);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _navigationTimer = Timer(
        widget.processingDuration,
        _openOrderConfirmation,
      );
    });
  }

  void _openOrderConfirmation() {
    if (!mounted || _navigationStarted) {
      return;
    }

    _navigationStarted = true;

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.orderConfirmation,
      arguments: widget.orderArguments,
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildProcessingAnimation(),
                    const SizedBox(height: 30),
                    Text(
                      _isCashOnDelivery
                          ? 'Confirming your order'
                          : 'Processing your payment',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isCashOnDelivery
                          ? 'Please wait while we reserve your fresh farm products.'
                          : 'Please do not close this screen or press the back button.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildOrderCard(),
                    const SizedBox(height: 22),
                    _buildProgressCard(),
                    const SizedBox(height: 18),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.lock_rounded,
                          color: AppColors.primary,
                          size: 15,
                        ),
                        SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Your order and payment details are secure',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildProcessingAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.82, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.elasticOut,
      builder: (
          BuildContext context,
          double scale,
          Widget? child,
          ) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: 132,
        height: 132,
        decoration: const BoxDecoration(
          color: Color(0xFFEAF7EF),
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x2217A45B),
              blurRadius: 32,
              offset: Offset(0, 13),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            const SizedBox(
              width: 104,
              height: 104,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                backgroundColor: Color(0xFFD5EEDF),
                strokeWidth: 5,
              ),
            ),
            Icon(
              _isCashOnDelivery
                  ? Icons.local_shipping_rounded
                  : Icons.verified_user_rounded,
              color: AppColors.primary,
              size: 48,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _buildDetailRow('Order number', _orderNumber),
          const SizedBox(height: 13),
          _buildDetailRow(
            'Payment method',
            _isCashOnDelivery ? 'Cash on Delivery' : 'Online Payment',
          ),
          const SizedBox(height: 13),
          _buildDetailRow(
            'Items',
            '$_itemCount ${_itemCount == 1 ? 'item' : 'items'}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          _buildDetailRow(
            _isCashOnDelivery ? 'Amount to pay' : 'Amount paid',
            _currency(_totalAmount),
            important: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label,
      String value, {
        bool important = false,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: important
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontSize: important ? 13 : 11,
              fontWeight: important
                  ? FontWeight.w900
                  : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: important
                  ? AppColors.primary
                  : AppColors.textPrimary,
              fontSize: important ? 18 : 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              _isCashOnDelivery
                  ? 'Creating your order confirmation...'
                  : 'Verifying payment and confirming order...',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _stringValue(
    dynamic value, {
      String fallback = '',
    }) {
  if (value == null) {
    return fallback;
  }

  final String text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

double _toDouble(
    dynamic value, {
      double fallback = 0,
    }) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
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

  return int.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

String _currency(double value) {
  if (value == value.roundToDouble()) {
    return '₹${value.toStringAsFixed(0)}';
  }

  return '₹${value.toStringAsFixed(2)}';
}
