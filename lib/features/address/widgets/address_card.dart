import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/address_model.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    this.onSetDefault,
    this.enabled = true,
  });

  final AddressModel address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onSelect : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF7EF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 12),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          address.type.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (address.isDefault) ...<Widget>[
                        const SizedBox(width: 6),
                        const Text(
                          'DEFAULT',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address.fullName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phone,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: <Widget>[
                      TextButton(onPressed: enabled ? onEdit : null, child: const Text('EDIT')),
                      TextButton(onPressed: enabled ? onDelete : null, child: const Text('DELETE')),
                      if (!address.isDefault && onSetDefault != null)
                        TextButton(
                          onPressed: enabled ? onSetDefault : null,
                          child: const Text('SET DEFAULT'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
