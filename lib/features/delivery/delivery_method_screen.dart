import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'preorder_delivery_screen.dart';
import 'quick_delivery_screen.dart';
import 'scheduled_delivery_screen.dart';

class DeliveryMethodScreen extends StatefulWidget {
  const DeliveryMethodScreen({
    super.key,
    required this.initialShoppingMode,
    required this.subtotal,
    required this.savings,
    required this.total,
    required this.itemCount,
  });

  final String initialShoppingMode;
  final double subtotal;
  final double savings;
  final double total;
  final int itemCount;

  @override
  State<DeliveryMethodScreen> createState() => _DeliveryMethodScreenState();
}

class _DeliveryMethodScreenState extends State<DeliveryMethodScreen> {
  late String _selectedMethod;

  bool get _isShopMode => widget.initialShoppingMode.trim().toLowerCase() == 'shop';

  @override
  void initState() {
    super.initState();
    _selectedMethod = _isShopMode ? 'scheduled' : 'quick';
  }

  void _continue() {
    final Widget screen;
    if (_selectedMethod == 'preorder') {
      screen = PreorderDeliveryScreen(
          shoppingMode: widget.initialShoppingMode,
          subtotal: widget.subtotal,
          savings: widget.savings,
          total: widget.total,
          itemCount: widget.itemCount,
        );
    } else if (_selectedMethod == 'scheduled') {
      screen = ScheduledDeliveryScreen(
          shoppingMode: widget.initialShoppingMode,
          subtotal: widget.subtotal,
          savings: widget.savings,
          total: widget.total,
          itemCount: widget.itemCount,
        );
    } else {
      screen = QuickDeliveryScreen(
          shoppingMode: widget.initialShoppingMode,
          subtotal: widget.subtotal,
          savings: widget.savings,
          total: widget.total,
          itemCount: widget.itemCount,
        );
    }
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Choose delivery'),
            Text('Freshness timed around your day', style: TextStyle(color: AppColors.textSecondary, fontSize: 8.5)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          _hero(),
          const SizedBox(height: 22),
          const Text('DELIVERY EXPERIENCES', style: TextStyle(color: AppColors.textSecondary, fontSize: 9, letterSpacing: 1.25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          if (!_isShopMode) ...<Widget>[
            _DeliveryChoice(
              selected: _selectedMethod == 'quick',
              icon: Icons.bolt_rounded,
              iconColor: const Color(0xFFF7A600),
              title: 'Quick delivery',
              badge: widget.total >= 499 ? 'FREE' : '₹49',
              time: '30–60 minutes',
              description: 'Priority picking and express doorstep delivery.',
              benefits: const <String>['Live tracking', 'Freshly packed'],
              onTap: () => setState(() => _selectedMethod = 'quick'),
            ),
            const SizedBox(height: 12),
          ],
          _DeliveryChoice(
            selected: _selectedMethod == 'scheduled',
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFF6750A4),
            title: 'Scheduled delivery',
            badge: _isShopMode ? '₹49' : '₹19',
            time: 'Choose date & 2-hour slot',
            description: _isShopMode ? 'Planned bulk delivery with careful handling.' : 'Pick a convenient window and skip the rush.',
            benefits: const <String>['10-day calendar', 'Flexible slots'],
            onTap: () => setState(() => _selectedMethod = 'scheduled'),
          ),
          const SizedBox(height: 12),
          _DeliveryChoice(
            selected: _selectedMethod == 'preorder',
            icon: Icons.eco_rounded,
            iconColor: AppColors.primary,
            title: 'Farm pre-order',
            badge: 'FREE',
            time: 'Delivered from day 3',
            description: 'Reserve produce closer to harvest for peak freshness.',
            benefits: const <String>['Harvest-first', 'Best freshness'],
            onTap: () => setState(() => _selectedMethod = 'preorder'),
          ),
          const SizedBox(height: 18),
          _OrderSnapshot(itemCount: widget.itemCount, total: widget.total, savings: widget.savings),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.paddingOf(context).bottom + 12),
        child: FilledButton.icon(
          onPressed: _continue,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF073D24),
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text('CONTINUE WITH ${_selectedMethod.toUpperCase()}'),
        ),
      ),
    );
  }

  Widget _hero() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF052F1C), Color(0xFF0B7A3E), Color(0xFF24A75E)],
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x250B7A3E), blurRadius: 26, offset: Offset(0, 12))],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_isShopMode ? 'Business-ready logistics' : 'Delivered your way', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  const Text('Every order is quality checked, sealed and trackable.', style: TextStyle(color: Color(0xFFD1EFDE), fontSize: 10, height: 1.4, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 9),
                  const Row(children: <Widget>[
                    Icon(Icons.shield_rounded, color: Color(0xFFFFD66B), size: 14),
                    SizedBox(width: 5),
                    Text('Freshness promise', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DeliveryChoice extends StatelessWidget {
  const _DeliveryChoice({
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.badge,
    required this.time,
    required this.description,
    required this.benefits,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String badge;
  final String time;
  final String description;
  final List<String> benefits;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(23),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE2EAE6), width: selected ? 1.7 : 1),
              boxShadow: selected ? const <BoxShadow>[BoxShadow(color: Color(0x160B7A3E), blurRadius: 20, offset: Offset(0, 8))] : null,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(width: 50, height: 50, decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.11), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: iconColor, size: 27)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(children: <Widget>[
                            Expanded(child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w900))),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: selected ? const Color(0xFFE6F6ED) : const Color(0xFFF1F4F2), borderRadius: BorderRadius.circular(12)), child: Text(badge, style: TextStyle(color: selected ? AppColors.primary : AppColors.textPrimary, fontSize: 9, fontWeight: FontWeight.w900))),
                          ]),
                          const SizedBox(height: 4),
                          Text(time, style: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: selected ? AppColors.primary : const Color(0xFFB9C3BE), size: 22),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: benefits.map((String benefit) => Expanded(child: Row(children: <Widget>[const Icon(Icons.check_rounded, color: AppColors.primary, size: 14), const SizedBox(width: 4), Text(benefit, style: const TextStyle(color: AppColors.textSecondary, fontSize: 8.5, fontWeight: FontWeight.w700))]))).toList(growable: false),
                ),
              ],
            ),
          ),
        ),
      );
}

class _OrderSnapshot extends StatelessWidget {
  const _OrderSnapshot({required this.itemCount, required this.total, required this.savings});
  final int itemCount;
  final double total;
  final double savings;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFFFFBEE), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1E4B5))),
        child: Row(children: <Widget>[
          const Icon(Icons.savings_rounded, color: Color(0xFFD79A00), size: 27),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('$itemCount items • ₹${total.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(savings > 0 ? 'You are saving ₹${savings.toStringAsFixed(0)} on this order' : 'Best available prices applied', style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ]),
      );
}
