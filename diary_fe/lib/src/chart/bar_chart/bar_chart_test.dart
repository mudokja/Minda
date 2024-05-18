import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartTest extends StatefulWidget {
  final List<double> emotions;

  const BarChartTest({
    super.key,
    required this.emotions,
  });

  @override
  State<BarChartTest> createState() => _BarChartTestState();
}

class _BarChartTestState extends State<BarChartTest> {
  late List<BarChartGroupData> _barGroups;

  @override
  void initState() {
    super.initState();
    _barGroups = _createBarGroups(widget.emotions);
  }

  @override
  void didUpdateWidget(covariant BarChartTest oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.emotions != oldWidget.emotions) {
      _barGroups = _createBarGroups(widget.emotions);
    }
  }

  List<BarChartGroupData> _createBarGroups(List<double> values) {
    const colors = [
      Color(0xFFF5AC25),
      Color(0xFFBC7FCD),
      Color(0xFFDF1E1E),
      Color(0xFF86469C),
      Color(0xFFFC819E),
    ];

    const maxValue = 10.0;

    return List.generate(values.length, (index) {
      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(
          toY: values[index].toDouble(),
          color: colors[index],
          width: 20,
          borderRadius: BorderRadius.zero,
        ),
        BarChartRodData(
          toY: maxValue,
          color: Colors.transparent,
          width: 0,
          borderRadius: BorderRadius.zero,
        ),
      ]);
    });
  }

  BarTouchData _createBarTouchData() => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.white,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItem: (group, groupIndex, rod, _) {
            if (rod.color == Colors.transparent) {
              return null;
            }

            const labels = [
              '기쁨',
              '슬픔',
              '불안',
              '분노',
              '놀람',
            ];
            final label = labels[group.x.toInt()];
            final value = rod.toY.toStringAsFixed(2);
            return BarTooltipItem(
              '$label: $value',
              TextStyle(
                color: rod.color,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: _barGroups,
        barTouchData: _createBarTouchData(),
        titlesData: const FlTitlesData(show: false),
      ),
      swapAnimationDuration: const Duration(milliseconds: 500),
      swapAnimationCurve: Curves.linear,
    );
  }
}
