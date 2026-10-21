import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/clp_formatter.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, num> data;

  const PieChartWidget({super.key, required this.data});

  static const _colors = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFFF97316),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('Sin gastos en este periodo',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ),
      );
    }

    final total = data.values.fold<num>(0, (sum, v) => sum + v);
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gastos por Categoria',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: PieChart(PieChartData(
                sections: entries.asMap().entries.map((e) {
                  final i = e.key;
                  final entry = e.value;
                  final pct =
                      total > 0 ? (entry.value / total * 100) : 0;
                  return PieChartSectionData(
                    color: _colors[i % _colors.length],
                    value: entry.value.toDouble(),
                    title: pct >= 5 ? '${pct.toStringAsFixed(0)}%' : '',
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    radius: 90,
                    titlePositionPercentageOffset: 0.55,
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              )),
            ),
            const SizedBox(height: 16),
            ...entries.asMap().entries.map((e) {
              final i = e.key;
              final entry = e.value;
              final pct = total > 0 ? (entry.value / total * 100) : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _colors[i % _colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(entry.key,
                            style: const TextStyle(fontSize: 14))),
                    Text('${pct.toStringAsFixed(0)}%',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: Text(formatCLP(entry.value),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
