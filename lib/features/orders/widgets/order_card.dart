import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/order_item_model.dart';
import '../../../data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onTrack,
    this.onCancel,
    this.onReorder,
    this.isProcessing = false,
  });

  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback? onTrack;
  final VoidCallback? onCancel;
  final VoidCallback? onReorder;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isProcessing ? null : onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(),
              const SizedBox(height: 15),
              _buildItemsPreview(),
              const SizedBox(height: 15),
              const Divider(height: 1),
              const SizedBox(height: 14),
              _buildDetails(),
              if (_hasActions) ...<Widget>[
                const SizedBox(height: 15),
                _buildActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasActions {
    return onTrack != null || onCancel != null || onReorder != null;
  }

  Widget _buildHeader() {
    final _OrderStatusStyle statusStyle = _statusStyle(order.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Order #${order.shortOrderId}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _formatDateTime(order.createdAt),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: statusStyle.background,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(statusStyle.icon, color: statusStyle.foreground, size: 13),
              const SizedBox(width: 5),
              Text(
                order.statusLabel.toUpperCase(),
                style: TextStyle(
                  color: statusStyle.foreground,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsPreview() {
    if (order.items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAF9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.shopping_basket_outlined,
              color: AppColors.primary,
              size: 23,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                '${order.calculatedItemCount} '
                '${order.calculatedItemCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(
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

    final List<OrderItemModel> visibleItems = order.items
        .take(3)
        .toList(growable: false);
    final int remainingCount = order.items.length - visibleItems.length;

    return Row(
      children: <Widget>[
        SizedBox(
          height: 58,
          width: visibleItems.length * 42.0 + 18,
          child: Stack(
            children: <Widget>[
              for (int index = 0; index < visibleItems.length; index++)
                Positioned(
                  left: index * 40,
                  child: _itemImage(visibleItems[index]),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _itemNames(visibleItems),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                remainingCount > 0
                    ? '+$remainingCount more • '
                        '${order.calculatedItemCount} items'
                    : '${order.calculatedItemCount} '
                        '${order.calculatedItemCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _itemImage(OrderItemModel item) {
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: _productImage(item.imageUrl),
      ),
    );
  }

  Widget _productImage(String path) {
    final String normalizedPath = path.trim();

    if (normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: normalizedPath,
        fit: BoxFit.contain,
        placeholder: (context, url) => _fallbackImage(),
        errorWidget: (context, url, error) => _fallbackImage(),
      );
    }

    if (normalizedPath.startsWith('assets/')) {
      return Image.asset(
        normalizedPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }

    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return const ColoredBox(
      color: Color(0xFFF2F8F4),
      child: Center(
        child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 25),
      ),
    );
  }

  Widget _buildDetails() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _smallDetail(
            icon: Icons.local_shipping_outlined,
            label: 'Delivery',
            value: order.deliveryMethodLabel,
          ),
        ),
        Container(width: 1, height: 35, color: AppColors.border),
        Expanded(
          child: _smallDetail(
            icon: Icons.payments_outlined,
            label: order.isCashOnDelivery ? 'Amount due' : 'Total paid',
            value: _currency(order.totalAmount),
            valueColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _smallDetail({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.primary, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor ?? AppColors.textPrimary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final List<Widget> actions = <Widget>[];

    if (onTrack != null && order.canTrack) {
      actions.add(
        Expanded(
          child: _actionButton(
            label: 'TRACK',
            icon: Icons.location_searching_rounded,
            onPressed: onTrack,
            filled: true,
          ),
        ),
      );
    }

    if (onCancel != null && order.canCancel) {
      if (actions.isNotEmpty) {
        actions.add(const SizedBox(width: 9));
      }

      actions.add(
        Expanded(
          child: _actionButton(
            label: 'CANCEL',
            icon: Icons.close_rounded,
            onPressed: onCancel,
          ),
        ),
      );
    }

    if (onReorder != null && order.canReorder) {
      if (actions.isNotEmpty) {
        actions.add(const SizedBox(width: 9));
      }

      actions.add(
        Expanded(
          child: _actionButton(
            label: 'REORDER',
            icon: Icons.refresh_rounded,
            onPressed: onReorder,
            filled: true,
          ),
        ),
      );
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: actions);
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool filled = false,
  }) {
    final Widget labelWidget =
        isProcessing
            ? SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: filled ? Colors.white : AppColors.primary,
              ),
            )
            : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            );

    if (filled) {
      return SizedBox(
        height: 42,
        child: FilledButton(
          onPressed: isProcessing ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          child: labelWidget,
        ),
      );
    }

    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: isProcessing ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: labelWidget,
      ),
    );
  }
}

class _OrderStatusStyle {
  const _OrderStatusStyle({
    required this.foreground,
    required this.background,
    required this.icon,
  });

  final Color foreground;
  final Color background;
  final IconData icon;
}

_OrderStatusStyle _statusStyle(String status) {
  switch (status) {
    case 'delivered':
      return const _OrderStatusStyle(
        foreground: Color(0xFF2E7D32),
        background: Color(0xFFE8F5E9),
        icon: Icons.check_circle_rounded,
      );
    case 'cancelled':
    case 'failed':
      return const _OrderStatusStyle(
        foreground: Color(0xFFC43131),
        background: Color(0xFFFFECEC),
        icon: Icons.cancel_rounded,
      );
    case 'shipped':
    case 'out_for_delivery':
      return const _OrderStatusStyle(
        foreground: Color(0xFF1565C0),
        background: Color(0xFFEAF3FF),
        icon: Icons.local_shipping_rounded,
      );
    case 'processing':
    case 'packed':
      return const _OrderStatusStyle(
        foreground: Color(0xFF9B6200),
        background: Color(0xFFFFF4D8),
        icon: Icons.inventory_2_rounded,
      );
    case 'confirmed':
      return const _OrderStatusStyle(
        foreground: Color(0xFF2E7D32),
        background: Color(0xFFE8F5E9),
        icon: Icons.verified_rounded,
      );
    case 'placed':
    default:
      return const _OrderStatusStyle(
        foreground: Color(0xFF2E7D32),
        background: Color(0xFFE8F5E9),
        icon: Icons.schedule_rounded,
      );
  }
}

String _itemNames(List<OrderItemModel> items) {
  return items.map((OrderItemModel item) => item.name).join(', ');
}

String _currency(double value) {
  if (value == value.roundToDouble()) {
    return '₹${value.toStringAsFixed(0)}';
  }

  return '₹${value.toStringAsFixed(2)}';
}

String _formatDateTime(DateTime? date) {
  if (date == null) {
    return 'Recently placed';
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
