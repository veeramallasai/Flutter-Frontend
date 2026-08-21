import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'card_option.dart';
import 'cod_option.dart';
import 'upi_option.dart';

enum PaymentMethodType {
  cashOnDelivery,
  googlePay,
  phonePe,
  upi,
  card,
  netBanking,
}

extension PaymentMethodTypeValue on PaymentMethodType {
  String get value {
    switch (this) {
      case PaymentMethodType.cashOnDelivery:
        return 'cash_on_delivery';
      case PaymentMethodType.googlePay:
        return 'google_pay';
      case PaymentMethodType.phonePe:
        return 'phone_pe';
      case PaymentMethodType.upi:
        return 'upi';
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.netBanking:
        return 'net_banking';
    }
  }
}

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
    this.enabled = true,
    this.onlinePaymentsEnabled = false,
  });

  final PaymentMethodType selectedMethod;
  final ValueChanged<PaymentMethodType> onChanged;
  final bool enabled;
  final bool onlinePaymentsEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'Choose Payment Method',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select a secure payment option to place your order.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 17),
        CodOption(
          selected: selectedMethod == PaymentMethodType.cashOnDelivery,
          enabled: enabled,
          onTap: () => onChanged(PaymentMethodType.cashOnDelivery),
        ),
        const SizedBox(height: 12),
        UpiOption.googlePay(
          selected: selectedMethod == PaymentMethodType.googlePay,
          enabled: enabled && onlinePaymentsEnabled,
          onTap: () => onChanged(PaymentMethodType.googlePay),
        ),
        const SizedBox(height: 12),
        UpiOption.phonePe(
          selected: selectedMethod == PaymentMethodType.phonePe,
          enabled: enabled && onlinePaymentsEnabled,
          onTap: () => onChanged(PaymentMethodType.phonePe),
        ),
        const SizedBox(height: 12),
        UpiOption.other(
          selected: selectedMethod == PaymentMethodType.upi,
          enabled: enabled && onlinePaymentsEnabled,
          onTap: () => onChanged(PaymentMethodType.upi),
        ),
        const SizedBox(height: 12),
        CardOption(
          selected: selectedMethod == PaymentMethodType.card,
          enabled: enabled && onlinePaymentsEnabled,
          onTap: () => onChanged(PaymentMethodType.card),
        ),
        const SizedBox(height: 12),
        _NetBankingOption(
          selected: selectedMethod == PaymentMethodType.netBanking,
          enabled: enabled && onlinePaymentsEnabled,
          onTap: () => onChanged(PaymentMethodType.netBanking),
        ),
      ],
    );
  }
}

class _NetBankingOption extends StatelessWidget {
  const _NetBankingOption({
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: selected ? const Color(0xFFF2FAF5) : Colors.white,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(21),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.7 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFEAF7EF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: selected ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Flexible(
                            child: Text(
                              'Net Banking',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4DA),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'COMING SOON',
                              style: TextStyle(
                                color: Color(0xFF9B6B08),
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Available after secure gateway activation',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
