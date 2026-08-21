import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/delivery_date_selector.dart';
import 'widgets/delivery_time_selector.dart';
import 'widgets/preorder_delivery_card.dart';
import 'widgets/preorder_notice.dart';

class PreorderDeliveryScreen extends StatefulWidget {
  const PreorderDeliveryScreen({
    super.key,
    required this.shoppingMode,
    required this.subtotal,
    required this.savings,
    required this.total,
    required this.itemCount,
  });

  final String shoppingMode;
  final double subtotal;
  final double savings;
  final double total;
  final int itemCount;

  @override
  State<PreorderDeliveryScreen> createState() => _PreorderDeliveryScreenState();
}

class _PreorderDeliveryScreenState extends State<PreorderDeliveryScreen> {
  late DateTime _selectedDate;
  String _selectedTime = '7:00 AM – 10:00 AM';

  static const List<String> _times = <String>[
    '7:00 AM – 10:00 AM',
    '10:00 AM – 1:00 PM',
    '3:00 PM – 6:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final DateTime date = DateTime.now().add(const Duration(days: 3));
    _selectedDate = DateTime(date.year, date.month, date.day);
  }

  void _continue() {
    Navigator.pushNamed(
      context,
      AppRoutes.addresses,
      arguments: <String, dynamic>{
        'shoppingMode': widget.shoppingMode,
        'deliveryMethod': 'preorder',
        'deliveryDate': _selectedDate.toIso8601String(),
        'deliverySlot': _selectedTime,
        'subtotal': widget.subtotal,
        'savings': widget.savings,
        'total': widget.total,
        'itemCount': widget.itemCount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pre-order Delivery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const _PreorderHero(),
          const SizedBox(height: 15),
          PreorderDeliveryCard(isSelected: true, onTap: () {}),
          const SizedBox(height: 13),
          const PreorderNotice(),
          const SizedBox(height: 20),
          DeliveryDateSelector(
            selectedDate: _selectedDate,
            startAfterDays: 3,
            numberOfDays: 14,
            onChanged: (DateTime date) => setState(() => _selectedDate = date),
          ),
          const SizedBox(height: 20),
          const Text(
            'Preferred Time',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          DeliveryTimeSelector(
            times: _times,
            selectedTime: _selectedTime,
            onChanged: (String value) => setState(() => _selectedTime = value),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _continue,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF073D24), minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
            icon: const Icon(Icons.eco_rounded),
            label: const Text('CONTINUE • FREE DELIVERY'),
          ),
        ),
      ),
    );
  }
}

class _PreorderHero extends StatelessWidget {
  const _PreorderHero();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: <Color>[Color(0xFF052F1C), Color(0xFF0B7A3E), Color(0xFF28A964)]),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x280B7A3E), blurRadius: 25, offset: Offset(0, 12))],
        ),
        child: const Row(children: <Widget>[
          CircleAvatar(radius: 31, backgroundColor: Color(0x24FFFFFF), child: Icon(Icons.eco_rounded, color: Colors.white, size: 36)),
          SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('Closer to the harvest', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            SizedBox(height: 5),
            Text('Reserve produce early and receive it at peak freshness.', style: TextStyle(color: Color(0xFFD4F2E2), fontSize: 10, height: 1.45, fontWeight: FontWeight.w600)),
          ])),
        ]),
      );
}
