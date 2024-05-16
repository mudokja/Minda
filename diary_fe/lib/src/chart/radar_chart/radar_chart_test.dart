import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RadarChartTest extends StatefulWidget {
  final List<double> emotions;

  const RadarChartTest({
    super.key,
    required this.emotions,
  });

  @override
  State<RadarChartTest> createState() => _RadarChartTestState();
}

class _RadarChartTestState extends State<RadarChartTest> {
  late List<RadarDataSet> _radarDataSets;

  @override
  void initState() {
    super.initState();
    _radarDataSets = _createRadarDataSets(widget.emotions);
  }

  @override
  void didUpdateWidget(covariant RadarChartTest oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.emotions != oldWidget.emotions) {
      _radarDataSets = _createRadarDataSets(widget.emotions);
    }
  }

  List<RadarDataSet> _createRadarDataSets(List<double> values) {
    const colors = [
      Color(0xFFF5AC25),
      Color(0xFFBC7FCD),
      Color(0xFFDF1E1E),
      Color(0xFF86469C),
      Color(0xFFFC819E),
    ];

    return [
      RadarDataSet(
        dataEntries:
            values.map((value) => RadarEntry(value: value.toDouble())).toList(),
        fillColor: Colors.blue.withOpacity(0.3),
        borderColor: Colors.blue,
        borderWidth: 2,
      ),
      RadarDataSet(
        entryRadius: 4,
        fillColor: Colors.transparent,
        borderColor: Colors.transparent,
        dataEntries: [
          const RadarEntry(value: 10),
          const RadarEntry(value: 10),
          const RadarEntry(value: 10),
          const RadarEntry(value: 10),
          const RadarEntry(value: 10),
        ],
      ),
    ];
  }

  RadarTouchData _createRadarTouchData() => RadarTouchData(
        enabled: false,
        // touchCallback: (event, response) {
        //   if (response != null && response.touchedSpot != null) {
        //     final touchedSpotIndex = response.touchedSpot!.touchedDataSetIndex;
        //     final touchedSpotValue =
        //         response.touchedSpot!.touchedRadarEntry.value;

        //     // 터치된 데이터의 인덱스와 값을 활용하여 원하는 동작 수행
        //     // 예: 터치된 데이터의 세부 정보 표시 등
        //     debugPrint(
        //         'Touched spot index: $touchedSpotIndex, value: $touchedSpotValue');
        //   }
        // },
        // touchSpotThreshold: 10,
      );

  @override
  Widget build(BuildContext context) {
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        radarTouchData: _createRadarTouchData(),
        dataSets: _radarDataSets,
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(
          show: false,
        ),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        getTitle: (index, angle) =>
            RadarChartTitle(text: ['기쁨', '슬픔', '불안', '분노', '놀람'][index]),
        tickCount: 5,
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        tickBorderData: BorderSide(color: Colors.grey.withAlpha(50)),
        gridBorderData: BorderSide(color: Colors.grey.withAlpha(120), width: 2),
        radarBorderData: BorderSide(color: Colors.grey.withAlpha(200)),
      ),
      swapAnimationDuration: const Duration(milliseconds: 500),
      swapAnimationCurve: Curves.linear,
    );
  }
}
