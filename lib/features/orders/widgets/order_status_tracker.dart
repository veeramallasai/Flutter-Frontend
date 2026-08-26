import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/order_model.dart';

class OrderStatusTracker extends StatelessWidget {
  const OrderStatusTracker({super.key, required this.order});

  final OrderModel order;

  static const List<_TrackingStep> _steps = <_TrackingStep>[
    _TrackingStep(
      status: 'placed',
      title: 'Order Placed',
      subtitle: 'We received your order.',
      icon: Icons.receipt_long_rounded,
    ),
    _TrackingStep(
      status: 'confirmed',
      title: 'Order Confirmed',
      subtitle: 'Your products are reserved.',
      icon: Icons.verified_rounded,
    ),
    _TrackingStep(
      status: 'processing',
      title: 'Preparing Order',
      subtitle: 'Fresh products are being packed.',
      icon: Icons.inventory_2_rounded,
    ),
    _TrackingStep(
      status: 'shipped',
      title: 'Order Shipped',
      subtitle: 'Your order has started its journey.',
      icon: Icons.local_shipping_rounded,
    ),
    _TrackingStep(
      status: 'out_for_delivery',
      title: 'Out for Delivery',
      subtitle: 'Your delivery partner is on the way.',
      icon: Icons.delivery_dining_rounded,
    ),
    _TrackingStep(
      status: 'delivered',
      title: 'Delivered',
      subtitle: 'Order delivered successfully.',
      icon: Icons.check_circle_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (order.isCancelled || order.isFailed) {
      return _buildStoppedState();
    }

    final int currentIndex = _currentStepIndex(order.status);

    return Column(
      children: <Widget>[
        for (int index = 0; index < _steps.length; index++)
          _buildStep(
            step: _steps[index],
            index: index,
            currentIndex: currentIndex,
            isLast: index == _steps.length - 1,
          ),
      ],
    );
  }

  Widget _buildStep({
    required _TrackingStep step,
    required int index,
    required int currentIndex,
    required bool isLast,
  }) {
    final bool completed = index < currentIndex;
    final bool current = index == currentIndex;
    final bool active = completed || current;
    final DateTime? time = _historyTimeFor(step.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 54,
            child: Column(
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color:
                        current
                            ? AppColors.primary
                            : completed
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active ? AppColors.primary : AppColors.border,
                      width: current ? 3 : 1.5,
                    ),
                    boxShadow:
                        current
                            ? const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x2517A45B),
                                blurRadius: 15,
                                offset: Offset(0, 6),
                              ),
                            ]
                            : null,
                  ),
                  child: Icon(
                    completed ? Icons.check_rounded : step.icon,
                    color:
                        current
                            ? Colors.white
                            : active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                    size: 23,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      constraints: const BoxConstraints(minHeight: 42),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: completed ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3, bottom: isLast ? 0 : 27),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          step.title,
                          style: TextStyle(
                            color:
                                active
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (current)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'CURRENT',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      color:
                          active
                              ? AppColors.textSecondary
                              : const Color(0xFFADB5B0),
                      fontSize: 10,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (time != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      _formatDateTime(time),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoppedState() {
    final bool cancelled = order.isCancelled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD1D1)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_rounded, color: AppColors.error),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  cancelled ? 'Order Cancelled' : 'Order Failed',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  cancelled
                      ? 'This order will not be delivered.'
                      : 'This order could not be completed.',
                  style: const TextStyle(
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

  int _currentStepIndex(String status) {
    switch (status) {
      case 'confirmed':
        return 1;
      case 'processing':
      case 'packed':
        return 2;
      case 'shipped':
        return 3;
      case 'out_for_delivery':
        return 4;
      case 'delivered':
        return 5;
      case 'placed':
      default:
        return 0;
    }
  }

  DateTime? _historyTimeFor(String status) {
    for (final OrderStatusHistoryEntry entry in order.statusHistory.reversed) {
      final String historyStatus = entry.status;

      if (historyStatus == status ||
          (status == 'processing' && historyStatus == 'packed')) {
        return entry.time;
      }
    }

    if (status == 'placed') {
      return order.createdAt;
    }

    return null;
  }
}

class _TrackingStep {
  const _TrackingStep({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String status;
  final String title;
  final String subtitle;
  final IconData icon;
}

String _formatDateTime(DateTime date) {
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

  final int hour =
      date.hour == 0
          ? 12
          : date.hour > 12
          ? date.hour - 12
          : date.hour;
  final String minute = date.minute.toString().padLeft(2, '0');
  final String period = date.hour >= 12 ? 'PM' : 'AM';

  return '${date.day.toString().padLeft(2, '0')} '
      '${months[date.month - 1]} ${date.year}, '
      '$hour:$minute $period';
}
