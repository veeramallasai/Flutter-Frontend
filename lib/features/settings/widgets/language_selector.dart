import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const List<_Language> languages = <_Language>[
      _Language(code: 'English', nativeName: 'English', subtitle: 'Default'),
      _Language(code: 'Telugu', nativeName: 'తెలుగు', subtitle: 'Telugu'),
      _Language(code: 'Hindi', nativeName: 'हिन्दी', subtitle: 'Hindi'),
    ];
    return RadioGroup<String>(
      groupValue: selected,
      onChanged: (String? value) {
        if (value != null) onChanged(value);
      },
      child: Column(
        children: languages
            .map(
              (_Language language) => RadioListTile<String>(
                value: language.code,
                activeColor: AppColors.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(
                  language.nativeName,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  language.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8.5,
                  ),
                ),
                secondary: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    language.nativeName.substring(0, 1),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _Language {
  const _Language({
    required this.code,
    required this.nativeName,
    required this.subtitle,
  });
  final String code;
  final String nativeName;
  final String subtitle;
}
