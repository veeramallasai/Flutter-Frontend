import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/order_model.dart';

typedef ReorderOrderCallback = Future<void> Function(OrderModel order);

class ReorderButton extends StatefulWidget {
  const ReorderButton({
    super.key,
    required this.order,
    required this.onReorder,
    this.onSuccess,
    this.onError,
    this.filled = true,
    this.label = 'REORDER',
    this.enabled = true,
  });

  final OrderModel order;
  final ReorderOrderCallback onReorder;
  final VoidCallback? onSuccess;
  final ValueChanged<Object>? onError;
  final bool filled;
  final String label;
  final bool enabled;

  @override
  State<ReorderButton> createState() => _ReorderButtonState();
}

class _ReorderButtonState extends State<ReorderButton> {
  bool _isLoading = false;

  bool get _canReorder =>
      widget.enabled && widget.order.canReorder && !_isLoading;

  Future<void> _handleReorder() async {
    if (!_canReorder) return;

    setState(() => _isLoading = true);

    try {
      await widget.onReorder(widget.order);
      if (mounted) widget.onSuccess?.call();
    } catch (error) {
      if (mounted) widget.onError?.call(error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor = widget.filled ? Colors.white : AppColors.primary;

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foregroundColor,
            ),
          )
        else
          Icon(Icons.refresh_rounded, size: 20, color: foregroundColor),
        const SizedBox(width: 8),
        Text(
          _isLoading ? 'ADDING...' : widget.label,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );

    if (widget.filled) {
      return SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: _canReorder ? _handleReorder : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.border,
            disabledForegroundColor: AppColors.textSecondary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: _canReorder ? _handleReorder : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textSecondary,
          side: BorderSide(
            color: _canReorder ? AppColors.primary : AppColors.border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      ),
    );
  }
}
