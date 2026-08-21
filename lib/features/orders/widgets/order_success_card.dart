import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/order_model.dart';

class OrderSuccessCard extends StatelessWidget {
  const OrderSuccessCard({
    super.key,
    required this.order,
    this.title = 'Order Placed Successfully!',
  });

  final OrderModel order;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFE7F7ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 52,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Thank you for choosing fresh products from Farm To Home.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: <Widget>[
                _SuccessDetailRow(
                  label: 'Order ID',
                  value: order.shortOrderId,
                ),
                const SizedBox(height: 11),
                _SuccessDetailRow(
                  label: 'Amount',
                  value: '₹${order.totalAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 11),
                _SuccessDetailRow(
                  label: 'Payment',
                  value: order.paymentStatusLabel,
                ),
                if (_deliveryText.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 11),
                  _SuccessDetailRow(
                    label: 'Delivery',
                    value: _deliveryText,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.notifications_active_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              SizedBox(width: 7),
              Flexible(
                child: Text(
                  'We will notify you when the order status changes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _deliveryText {
    final String date = order.deliveryDate?.trim() ?? '';
    final String slot = order.deliverySlot.trim();

    if (date.isNotEmpty && slot.isNotEmpty) return '$date, $slot';
    if (date.isNotEmpty) return date;
    if (slot.isNotEmpty) return slot;
    return order.deliveryMethodLabel;
  }
}

class _SuccessDetailRow extends StatelessWidget {
  const _SuccessDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
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
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
