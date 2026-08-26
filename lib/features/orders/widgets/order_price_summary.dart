import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/order_model.dart';

class OrderPriceSummary extends StatelessWidget {
  const OrderPriceSummary({
    super.key,
    required this.order,
    this.showSavingsMessage = true,
  });

  final OrderModel order;
  final bool showSavingsMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'PRICE DETAILS',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _PriceRow(
            label: 'Items total (${order.calculatedItemCount})',
            amount: order.mrpTotal,
          ),
          if (order.productSavings > 0) ...<Widget>[
            const SizedBox(height: 11),
            _PriceRow(
              label: 'Product discount',
              amount: -order.productSavings,
              highlight: true,
            ),
          ],
          if (order.couponDiscount > 0) ...<Widget>[
            const SizedBox(height: 11),
            _PriceRow(
              label:
                  order.couponCode.trim().isEmpty
                      ? 'Coupon discount'
                      : 'Coupon (${order.couponCode})',
              amount: -order.couponDiscount,
              highlight: true,
            ),
          ],
          const SizedBox(height: 11),
          _PriceRow(
            label: 'Delivery fee',
            amount: order.deliveryFee,
            freeWhenZero: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _PriceRow(
            label: 'Amount paid',
            amount: order.totalAmount,
            isTotal: true,
          ),
          if (showSavingsMessage && order.totalSavings > 0) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.savings_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You saved ₹${order.totalSavings.toStringAsFixed(2)} on this order',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    this.highlight = false,
    this.freeWhenZero = false,
    this.isTotal = false,
  });

  final String label;
  final double amount;
  final bool highlight;
  final bool freeWhenZero;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final bool isDiscount = amount < 0;
    final Color color =
        highlight
            ? AppColors.primary
            : isTotal
            ? AppColors.textPrimary
            : AppColors.textSecondary;

    final String value;
    if (freeWhenZero && amount == 0) {
      value = 'FREE';
    } else if (isDiscount) {
      value = '- ₹${amount.abs().toStringAsFixed(2)}';
    } else {
      value = '₹${amount.toStringAsFixed(2)}';
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isTotal ? 14 : 11,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color:
                (highlight || (freeWhenZero && amount == 0))
                    ? AppColors.primary
                    : AppColors.textPrimary,
            fontSize: isTotal ? 15 : 12,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
