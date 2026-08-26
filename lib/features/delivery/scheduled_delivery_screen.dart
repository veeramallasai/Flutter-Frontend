import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/delivery_date_selector.dart';
import 'widgets/delivery_time_selector.dart';
import 'widgets/scheduled_delivery_card.dart';

class ScheduledDeliveryScreen extends StatefulWidget {
  const ScheduledDeliveryScreen({
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
  State<ScheduledDeliveryScreen> createState() =>
      _ScheduledDeliveryScreenState();
}

class _ScheduledDeliveryScreenState extends State<ScheduledDeliveryScreen> {
  late DateTime _selectedDate;
  String _selectedTime = '10:00 AM – 12:00 PM';

  static const List<String> _times = <String>[
    '7:00 AM – 9:00 AM',
    '10:00 AM – 12:00 PM',
    '2:00 PM – 4:00 PM',
    '5:00 PM – 7:00 PM',
  ];

  double get _fee => widget.shoppingMode.toLowerCase() == 'shop' ? 49 : 19;

  @override
  void initState() {
    super.initState();
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    _selectedDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  void _continue() {
    Navigator.pushNamed(
      context,
      AppRoutes.addresses,
      arguments: <String, dynamic>{
        'shoppingMode': widget.shoppingMode,
        'deliveryMethod': 'scheduled',
        'deliveryDate': _selectedDate.toIso8601String(),
        'deliverySlot': _selectedTime,
        'subtotal': widget.subtotal,
        'savings': widget.savings,
        'total': widget.total + _fee,
        'itemCount': widget.itemCount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Scheduled Delivery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const _ScheduledHero(),
          const SizedBox(height: 15),
          ScheduledDeliveryCard(isSelected: true, onTap: () {}),
          const SizedBox(height: 20),
          DeliveryDateSelector(
            selectedDate: _selectedDate,
            startAfterDays: 1,
            numberOfDays: 10,
            onChanged: (DateTime date) => setState(() => _selectedDate = date),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Time Slot',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
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
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.calendar_month_rounded),
            label: Text('RESERVE SLOT • ₹${_fee.toStringAsFixed(0)}'),
          ),
        ),
      ),
    );
  }
}

class _ScheduledHero extends StatelessWidget {
  const _ScheduledHero();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: <Color>[
          Color(0xFF241743),
          Color(0xFF594194),
          Color(0xFF7D64BA),
        ],
      ),
      borderRadius: BorderRadius.circular(26),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x28594194),
          blurRadius: 25,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: const Row(
      children: <Widget>[
        CircleAvatar(
          radius: 31,
          backgroundColor: Color(0x24FFFFFF),
          child: Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Delivery on your time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Reserve a convenient 2-hour window with predictable arrival.',
                style: TextStyle(
                  color: Color(0xFFE5DCFF),
                  fontSize: 10,
                  height: 1.45,
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
