import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DeliveryMethodSelector extends StatelessWidget {
  const DeliveryMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
    this.allowQuick = true,
  });

  final String selectedMethod;
  final ValueChanged<String> onChanged;
  final bool allowQuick;

  @override
  Widget build(BuildContext context) {
    final List<_Method> methods = <_Method>[
      if (allowQuick)
        const _Method('quick', 'Quick', '30–60 min', Icons.bolt_rounded),
      const _Method('scheduled', 'Scheduled', 'Choose date', Icons.event_rounded),
      const _Method('preorder', 'Pre-order', 'Future harvest', Icons.eco_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Delivery Method',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 11),
        Row(
          children: methods.map((_Method method) {
            final bool selected = method.value == selectedMethod;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: method == methods.last ? 0 : 8),
                child: InkWell(
                  onTap: () => onChanged(method.value),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFE4F6EB) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Icon(method.icon, color: AppColors.primary, size: 23),
                        const SizedBox(height: 6),
                        Text(
                          method.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          method.subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

class _Method {
  const _Method(this.value, this.title, this.subtitle, this.icon);
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
}
