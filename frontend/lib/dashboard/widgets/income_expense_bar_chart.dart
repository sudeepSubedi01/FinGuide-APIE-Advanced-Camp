import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/timeline_stat_model.dart';

class IncomeExpenseBarChart extends StatelessWidget {
  final List<TimelineStat> stats;

  const IncomeExpenseBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          children: [
            Container(width: 12, height: 12, color: Colors.greenAccent),
            const SizedBox(width: 4),
            const Text("Income", style: TextStyle(color: Colors.white70)),
            const SizedBox(width: 16),
            Container(width: 12, height: 12, color: Colors.redAccent),
            const SizedBox(width: 4),
            const Text("Expense", style: TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 8),

        // Bar chart
        SizedBox(
          height: 260,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: stats.asMap().entries.map((entry) {
                int index = entry.key;
                final stat = entry.value;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: stat.income,
                      width: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.greenAccent,
                    ),
                    BarChartRodData(
                      toY: stat.expense,
                      width: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.redAccent,
                    ),
                  ],
                );
              }).toList(),

              // Titles (axes)
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < stats.length) {
                        final date = stats[index].date.substring(5); // MM-DD
                        return Text(
                          date,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),

                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),

              borderData: FlBorderData(show: false),

              // Mild horizontal lines
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval: 500,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white24,
                    strokeWidth: 0.5,
                  );
                },
              ),

              // Touch tooltips
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date = stats[group.x.toInt()].date.substring(5);
                    final type = rodIndex == 0 ? "Income" : "Expense";
                    return BarTooltipItem(
                      "$date\n$type: ${rod.toY.toInt()}",
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
