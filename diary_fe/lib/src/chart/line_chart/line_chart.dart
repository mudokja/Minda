import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartTest extends StatefulWidget {
  const LineChartTest({super.key});

  @override
  State<LineChartTest> createState() => _LineChartTestState();
}

class _LineChartTestState extends State<LineChartTest> {
  late final List<List<FlSpot>> _spots;

  @override
  void initState() {
    super.initState();
    _spots = _createSpots();
  }

  // 여기서 각각의 감정별로 데이터 포인트를 생성합니다.
  List<List<FlSpot>> _createSpots() {
    final weekData = {
      '기쁨': [3, 5.5, 2, 6, 3.5, 7, 4],
      '슬픔': [2, 3, 4, 3, 2.5, 2, 1],
      '불안': [5, 3, 4, 2, 6, 5, 3],
      '분노': [1, 2, 2, 3, 4, 5, 2],
      '상처': [2, 2, 2, 2, 3, 3, 2],
      '놀람': [1, 3, 3, 1, 4, 3, 2]
    };
    return weekData.entries
        .map((entry) => List.generate(entry.value.length,
            (index) => FlSpot(index.toDouble(), entry.value[index].toDouble())))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xff845EC2), // 기쁨
      const Color(0xffD65DB1), // 슬픔
      const Color(0xffFF6F91), // 불안
      const Color(0xffFF9671), // 분노
      const Color(0xffFFC75F), // 상처
      const Color(0xffF9F871), // 놀람
    ];
    final labels = ['기쁨', '슬픔', '불안', '분노', '상처', '놀람'];

    return LineChart(
      curve: Curves.linear,
      LineChartData(
        lineTouchData: const LineTouchData(
          enabled: true,
          // touchTooltipData: LineTouchTooltipData(
          //   getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          //     return touchedBarSpots.map((barSpot) {
          //       const textStyle = TextStyle(
          //         color: Colors.black,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 14,
          //       );
          //       return LineTooltipItem(
          //         '${dateFormat.format(_dates[barSpot.x.toInt()])}\n${labels[barSpot.barIndex]}: ${barSpot.y}',
          //         textStyle,
          //       );
          //     }).toList();
          //   },
          // ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: List.generate(_spots.length, (index) {
          return LineChartBarData(
            spots: _spots[index],
            color: colors[index],
            barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          );
        }),
        titlesData: const FlTitlesData(show: false),
      ),
    );
  }
}
