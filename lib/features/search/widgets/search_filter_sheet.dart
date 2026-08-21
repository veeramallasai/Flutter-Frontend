import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SearchFilterSelection {
  const SearchFilterSelection({
    this.category = 'all',
    this.sort = 'recommended',
    this.offersOnly = false,
  });

  final String category;
  final String sort;
  final bool offersOnly;

  bool get isActive => category != 'all' || sort != 'recommended' || offersOnly;
}

Future<SearchFilterSelection?> showSearchFilterSheet(
  BuildContext context, {
  required SearchFilterSelection initial,
}) {
  String category = initial.category;
  String sort = initial.sort;
  bool offersOnly = initial.offersOnly;
  return showModalBottomSheet<SearchFilterSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setSheetState) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(20)))),
              const SizedBox(height: 18),
              const Text('Filter & sort', style: TextStyle(color: AppColors.textPrimary, fontSize: 21, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              const Text('CATEGORY', style: TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <String>['all', 'vegetables', 'fruits', 'dairy', 'seasonal']
                    .map((String value) => ChoiceChip(
                          label: Text(value == 'all' ? 'All' : '${value[0].toUpperCase()}${value.substring(1)}'),
                          selected: category == value,
                          onSelected: (_) => setSheetState(() => category = value),
                        ))
                    .toList(growable: false),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: sort,
                decoration: const InputDecoration(labelText: 'Sort products'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'recommended', child: Text('Recommended')),
                  DropdownMenuItem(value: 'low', child: Text('Price: Low to High')),
                  DropdownMenuItem(value: 'high', child: Text('Price: High to Low')),
                  DropdownMenuItem(value: 'rating', child: Text('Top Rated')),
                  DropdownMenuItem(value: 'discount', child: Text('Best Discount')),
                ],
                onChanged: (String? value) => setSheetState(() => sort = value ?? 'recommended'),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Offers only', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Show products with active savings'),
                value: offersOnly,
                onChanged: (bool value) => setSheetState(() => offersOnly = value),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, const SearchFilterSelection()),
                      child: const Text('RESET'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(
                        sheetContext,
                        SearchFilterSelection(category: category, sort: sort, offersOnly: offersOnly),
                      ),
                      child: const Text('APPLY FILTERS'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
