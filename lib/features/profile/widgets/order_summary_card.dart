import 'package:flutter/material.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.totalOrders,
    required this.activeOrders,
    required this.totalSavings,
    required this.onTap,
  });

  final int totalOrders;
  final int activeOrders;
  final double totalSavings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF073D24),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x26073D24), blurRadius: 22, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                children: <Widget>[
                  Icon(Icons.receipt_long_rounded, color: Color(0xFFFFD66B)),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Order overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 19),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(child: _Stat(value: '$totalOrders', label: 'TOTAL ORDERS')),
                  const _Divider(),
                  Expanded(child: _Stat(value: '$activeOrders', label: 'ACTIVE')),
                  const _Divider(),
                  Expanded(
                    child: _Stat(
                      value: '₹${totalSavings.toStringAsFixed(0)}',
                      label: 'SAVED',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFBCE4CD),
              fontSize: 7,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 38, color: const Color(0x33FFFFFF));
}
