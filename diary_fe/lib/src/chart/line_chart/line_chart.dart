import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartTest extends StatefulWidget {
  final Map<String, List<double>> emotionsData;
  const LineChartTest({
    super.key,
    required this.emotionsData,
  });

  @override
  State<LineChartTest> createState() => _LineChartTestState();
}

class _LineChartTestState extends State<LineChartTest> {
  List<List<FlSpot>>? _spots;

  @override
  void initState() {
    super.initState();
    _spots = _createSpots();
  }

  @override
  void didUpdateWidget(covariant LineChartTest oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emotionsData != widget.emotionsData) {
      _spots = _createSpots();
    }
  }

  List<List<FlSpot>> _createSpots() {
    List<List<FlSpot>> spots = [];

    var sortedEntries = widget.emotionsData.entries.toList()
      ..sort((a, b) => DateTime.parse(a.key).compareTo(DateTime.parse(b.key)));

    for (var entry in sortedEntries) {
      List<double> emotions = entry.value;
      DateTime date = DateTime.parse(entry.key);
      for (int i = 0; i < emotions.length; i++) {
        if (spots.length <= i) {
          spots.add([]);
        }
        spots[i].add(FlSpot(
          date.millisecondsSinceEpoch.toDouble(),
          emotions[i].toDouble(),
        ));
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['기쁨', '슬픔', '불안', '분노', '놀람'];
    final colors = [
      const Color(0xff845EC2), // 기쁨
      const Color(0xffD65DB1), // 슬픔
      const Color(0xffFF6F91), // 불안
      const Color(0xffFF9671), // 분노
      const Color(0xffFFC75F), // 놀람
    ];

    return LineChart(
      curve: Curves.linear,
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) {
              return Colors.white;
            },
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              List<LineTooltipItem> tooltipItems = [];
              for (int i = 0; i < touchedSpots.length; i++) {
                final spot = touchedSpots[i];
                final textStyle = TextStyle(
                    color: spot.bar.color, fontWeight: FontWeight.bold);
                String tooltipText = (i == 0)
                    ? '${DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()).year}-${DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()).month.toString().padLeft(2, '0')}-${DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()).day.toString().padLeft(2, '0')}\n'
                    : '';
                tooltipText +=
                    '${labels[spot.barIndex]}: ${spot.y.toStringAsFixed(2)}';

                tooltipItems.add(LineTooltipItem(tooltipText, textStyle));
              }
              return tooltipItems;
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: List.generate(_spots?.length ?? 0, (index) {
          return LineChartBarData(
            shadow: const Shadow(
              color: Colors.white,
              blurRadius: 0.5,
            ),
            spots: _spots![index],
            color: colors[index],
            barWidth: 2.6,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          );
        }),
        titlesData: const FlTitlesData(show: false),
      ),
    );
  }
}
