import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RadarChartTest extends StatefulWidget {
  const RadarChartTest({super.key});

  @override
  State<RadarChartTest> createState() => _RadarChartTestState();
}

class _RadarChartTestState extends State<RadarChartTest> {
  late final List<RadarDataSet> _radarDataSets;

  @override
  void initState() {
    super.initState();
    _radarDataSets = _createRadarDataSets();
  }

  List<RadarDataSet> _createRadarDataSets() {
    const dataEntries = [
      [29.0, 5.0, 8.0, 40.13, 12.0, 38.0],
    ];
    const colors = [
      Color(0xff845EC2),
      Color(0xffD65DB1),
      Color(0xffFF6F91),
      Color(0xffFF9671),
      Color(0xffFFC75F),
      Color(0xffF9F871),
    ];

    return List.generate(dataEntries.length, (index) {
      return RadarDataSet(
        dataEntries: dataEntries[index]
            .map((value) => RadarEntry(value: value))
            .toList(),
        fillColor: Colors.blue.withOpacity(0.3),
        borderColor: Colors.blue,
        borderWidth: 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        radarTouchData: RadarTouchData(enabled: true),
        dataSets: _radarDataSets,
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        getTitle: (index, angle) {
          const titles = [
            '기쁨',
            '슬픔',
            '불안',
            '분노',
            '상처',
            '놀람',
          ];
          return RadarChartTitle(
            text: titles[index],
          ); // RadarChartTitle 객체를 사용
        },
        tickCount: 5,
        ticksTextStyle: const TextStyle(
          color: Colors.transparent,
        ),
        tickBorderData: BorderSide(
          color: Colors.grey.withAlpha(50),
        ),
        gridBorderData: BorderSide(
          color: Colors.grey.withAlpha(120),
          width: 2,
        ),
        radarBorderData: BorderSide(
          color: Colors.grey.withAlpha(200),
        ),
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }
}
