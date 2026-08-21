import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/order_model.dart';

class DeliveryStatusTimeline extends StatelessWidget {
  const DeliveryStatusTimeline({
    super.key,
    required this.order,
    this.compact = false,
  });

  final OrderModel order;
  final bool compact;

  static const List<_DeliveryStep> _steps = <_DeliveryStep>[
    _DeliveryStep('Placed', Icons.receipt_long_rounded),
    _DeliveryStep('Processing', Icons.inventory_2_rounded),
    _DeliveryStep('Shipped', Icons.local_shipping_rounded),
    _DeliveryStep('Delivered', Icons.home_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    if (order.isCancelled || order.isFailed) {
      return _StoppedDeliveryStatus(cancelled: order.isCancelled);
    }

    final int activeIndex = _activeIndex(order.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(_steps.length, (int index) {
        final bool active = index <= activeIndex;
        final bool complete = index < activeIndex;
        final _DeliveryStep step = _steps[index];

        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: compact ? 30 : 38,
                      height: compact ? 30 : 38,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : const Color(0xFFF1F4F2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: active
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        complete ? Icons.check_rounded : step.icon,
                        size: compact ? 16 : 19,
                        color: active
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: compact ? 5 : 8),
                    Text(
                      step.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: active
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontSize: compact ? 8 : 10,
                        fontWeight:
                        active ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (index != _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.only(top: compact ? 14 : 18),
                    decoration: BoxDecoration(
                      color: index < activeIndex
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  int _activeIndex(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'processing':
      case 'packed':
        return 1;
      case 'shipped':
      case 'out_for_delivery':
        return 2;
      case 'delivered':
        return 3;
      case 'placed':
      default:
        return 0;
    }
  }
}

class _StoppedDeliveryStatus extends StatelessWidget {
  const _StoppedDeliveryStatus({required this.cancelled});

  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD1D1)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 9),
          Text(
            cancelled ? 'Order cancelled' : 'Order could not be completed',
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryStep {
  const _DeliveryStep(this.label, this.icon);

  final String label;
  final IconData icon;
}
