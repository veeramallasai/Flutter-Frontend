import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CartCouponSection extends StatefulWidget {
  const CartCouponSection({
    super.key,
    required this.currentCode,
    required this.discount,
    required this.onApply,
    required this.onRemove,
    this.isLoading = false,
  });

  final String currentCode;
  final double discount;
  final Future<void> Function(String code) onApply;
  final Future<void> Function() onRemove;
  final bool isLoading;

  @override
  State<CartCouponSection> createState() => _CartCouponSectionState();
}

class _CartCouponSectionState extends State<CartCouponSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentCode);
  }

  @override
  void didUpdateWidget(CartCouponSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCode != widget.currentCode) {
      _controller.text = widget.currentCode;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool applied = widget.currentCode.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.confirmation_number_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 7),
              Text(
                'Apply Coupon',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          if (applied)
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.currentCode.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Coupon saving ₹${widget.discount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: widget.isLoading ? null : widget.onRemove,
                  child: const Text('REMOVE'),
                ),
              ],
            )
          else
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !widget.isLoading,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF7F9F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                FilledButton(
                  onPressed: widget.isLoading
                      ? null
                      : () => widget.onApply(_controller.text.trim()),
                  child: const Text('APPLY'),
                ),
              ],
            ),
          if (!applied) ...<Widget>[
            const SizedBox(height: 7),
            const Text(
              'Try FRESH10 or WELCOME50',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
