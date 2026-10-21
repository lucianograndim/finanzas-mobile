import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/constants.dart';

class PeriodSelector extends StatelessWidget {
  final int month;
  final int year;
  final void Function(int month, int year) onChanged;

  const PeriodSelector({
    super.key,
    required this.month,
    required this.year,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = [currentYear - 1, currentYear];

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: month,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                        value: i + 1, child: Text(months[i]))),
                onChanged: (v) {
                  if (v != null) onChanged(v, year);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: year,
              dropdownColor: AppColors.surface,
              items: years
                  .map((y) => DropdownMenuItem(
                      value: y, child: Text(y.toString())))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(month, v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
