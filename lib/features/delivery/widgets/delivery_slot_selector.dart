import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/delivery_slot_model.dart';

class DeliverySlotSelector extends StatelessWidget {
  const DeliverySlotSelector({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onChanged,
    this.isLoading = false,
  });

  final List<DeliverySlotModel> slots;
  final DeliverySlotModel? selectedSlot;
  final ValueChanged<DeliverySlotModel> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (slots.isEmpty) {
      return const Text(
        'No slots available for this date.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
      );
    }
    return Column(
      children: slots
          .map((DeliverySlotModel slot) {
            final bool selected = selectedSlot?.id == slot.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: selected ? const Color(0xFFE8F5E9) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  enabled: slot.canBook,
                  onTap: slot.canBook ? () => onChanged(slot) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  title: Text(
                    slot.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    slot.canBook
                        ? '${slot.startTime} – ${slot.endTime}'
                        : 'Slot full',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 8.5,
                    ),
                  ),
                  trailing: Text(
                    slot.fee <= 0 ? 'FREE' : '₹${slot.fee.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
