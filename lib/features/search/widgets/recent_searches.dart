import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.queries,
    required this.onSelected,
    required this.onClear,
  });

  final List<String> queries;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (queries.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Recent searches',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(onPressed: onClear, child: const Text('CLEAR')),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: queries
              .map(
                (String query) => ActionChip(
                  avatar: const Icon(Icons.history_rounded, size: 16),
                  label: Text(query),
                  onPressed: () => onSelected(query),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
