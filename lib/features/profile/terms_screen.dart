import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('Terms of Service')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      children: const <Widget>[
        _TermsHero(),
        SizedBox(height: 18),
        _Section(
          number: '01',
          title: 'Using Farm To Home',
          text:
              'Use accurate account, address and contact information. You are responsible for activities performed through your account.',
        ),
        _Section(
          number: '02',
          title: 'Product freshness',
          text:
              'Fresh produce may naturally vary in colour, size and weight. We quality-check products before packing and delivery.',
        ),
        _Section(
          number: '03',
          title: 'Prices and savings',
          text:
              'Prices, MRP, discounts and availability can change by product, shopping mode and delivery location. The checkout total is final for that order.',
        ),
        _Section(
          number: '04',
          title: 'Delivery',
          text:
              'Delivery estimates depend on the selected method, address, slot and external conditions. Keep the registered phone available for delivery coordination.',
        ),
        _Section(
          number: '05',
          title: 'Payments and refunds',
          text:
              'Online payment status is confirmed by the payment service. Eligible refunds are processed after order and quality verification.',
        ),
        _Section(
          number: '06',
          title: 'Support',
          text:
              'For product, delivery or payment concerns, raise a support request with the relevant order ID and clear details.',
        ),
        SizedBox(height: 8),
        Text(
          'Last updated: August 2026',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
        ),
      ],
    ),
  );
}

class _TermsHero extends StatelessWidget {
  const _TermsHero();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: <Color>[Color(0xFF1B5E20), Color(0xFF2E7D32)],
      ),
      borderRadius: BorderRadius.circular(26),
    ),
    child: const Row(
      children: <Widget>[
        Icon(Icons.description_rounded, color: Color(0xFFFFB300), size: 42),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Simple, transparent terms',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'The essentials for shopping fresh with confidence.',
                style: TextStyle(color: Color(0xFFC9E7D6), fontSize: 9.5),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({
    required this.number,
    required this.title,
    required this.text,
  });
  final String number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 11),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          number,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
