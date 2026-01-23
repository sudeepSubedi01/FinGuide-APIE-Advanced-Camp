import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/category_stat_model.dart';

class ExpensePieChart extends StatelessWidget {
  final List<CategoryStat> categoryStats;

  const ExpensePieChart({super.key, required this.categoryStats});

  @override
  Widget build(BuildContext context) {
    if (categoryStats.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            "No expense data",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 50,
          sections: _sections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _sections() {
    final total = categoryStats.fold<double>(
      0,
      (sum, item) => sum + item.expense,
    );

    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.red,
      Colors.purple,
      Colors.green,
      Colors.yellow,
    ];

    return categoryStats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final percentage = (stat.expense / total) * 100;

      return PieChartSectionData(
        value: stat.expense,
        color: colors[index % colors.length],
        radius: 60,
        title: "${percentage.toStringAsFixed(1)}%",
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }).toList();
  }
}
