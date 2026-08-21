import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/quick_delivery_card.dart';

class QuickDeliveryScreen extends StatelessWidget {
  const QuickDeliveryScreen({
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

  double get deliveryFee => total >= 499 ? 0 : 49;

  void _continue(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.addresses,
      arguments: <String, dynamic>{
        'shoppingMode': shoppingMode,
        'deliveryMethod': 'quick',
        'deliveryDate': DateTime.now().toIso8601String(),
        'deliverySlot': 'Within 30–60 minutes',
        'subtotal': subtotal,
        'savings': savings,
        'total': total + deliveryFee,
        'itemCount': itemCount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quick Delivery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const _QuickHero(),
          const SizedBox(height: 15),
          QuickDeliveryCard(
            isSelected: true,
            onTap: () {},
            fee: deliveryFee,
          ),
          const SizedBox(height: 18),
          const _Feature(
            icon: Icons.schedule_rounded,
            title: '30–60 minute delivery',
            subtitle: 'Estimated from the time your order is confirmed.',
          ),
          const SizedBox(height: 10),
          const _Feature(
            icon: Icons.eco_rounded,
            title: 'Freshly packed',
            subtitle: 'Products are picked and packed after order confirmation.',
          ),
          const SizedBox(height: 10),
          const _Feature(
            icon: Icons.notifications_active_rounded,
            title: 'Live status updates',
            subtitle: 'Track packing and delivery from My Orders.',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => _continue(context),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF073D24),
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.bolt_rounded),
            label: Text(
              deliveryFee <= 0
                  ? 'CONTINUE • FREE DELIVERY'
                  : 'CONTINUE • ₹${deliveryFee.toStringAsFixed(0)}',
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickHero extends StatelessWidget {
  const _QuickHero();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: <Color>[Color(0xFF352300), Color(0xFF9A6400), Color(0xFFF3A712)]),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x30C28200), blurRadius: 25, offset: Offset(0, 12))],
        ),
        child: const Row(children: <Widget>[
          CircleAvatar(radius: 31, backgroundColor: Color(0x24FFFFFF), child: Icon(Icons.bolt_rounded, color: Colors.white, size: 37)),
          SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('Freshness at full speed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            SizedBox(height: 5),
            Text('Priority picked, quality checked and delivered in 30–60 minutes.', style: TextStyle(color: Color(0xFFFFE8B6), fontSize: 10, height: 1.45, fontWeight: FontWeight.w600)),
          ])),
        ]),
      );
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 10.5, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 8.5, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
