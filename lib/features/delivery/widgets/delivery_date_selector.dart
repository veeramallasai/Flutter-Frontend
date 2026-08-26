import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DeliveryDateSelector extends StatelessWidget {
  const DeliveryDateSelector({
    super.key,
    required this.selectedDate,
    required this.onChanged,
    this.startAfterDays = 0,
    this.numberOfDays = 7,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;
  final int startAfterDays;
  final int numberOfDays;

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final List<DateTime> dates = List<DateTime>.generate(
      numberOfDays,
      (int index) => DateTime(
        today.year,
        today.month,
        today.day,
      ).add(Duration(days: startAfterDays + index)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Select Date',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 77,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, int index) {
              final DateTime date = dates[index];
              final bool selected = _sameDay(date, selectedDate);
              return InkWell(
                onTap: () => onChanged(date),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 62,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _weekdays[date.weekday - 1],
                        style: TextStyle(
                          color:
                              selected
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color:
                              selected ? Colors.white : AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        _months[date.month - 1],
                        style: TextStyle(
                          color:
                              selected
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

bool _sameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

const List<String> _weekdays = <String>[
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT',
  'SUN',
];
const List<String> _months = <String>[
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];
