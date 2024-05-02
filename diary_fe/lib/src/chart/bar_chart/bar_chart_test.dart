import 'package:diary_fe/src/models/analysis_model.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartTest extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const BarChartTest({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<BarChartTest> createState() => _BarChartTestState();
}

class _BarChartTestState extends State<BarChartTest> {
  List<BarChartGroupData> _barGroups = [];
  final ApiService _apiService = ApiService();

  String formatDate(DateTime dateTime) {
    String formattedDate =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    _initializeChartData();
    fetchData();
  }

  void _initializeChartData() {
    List<int> initialEmotions = [0, 0, 0, 0, 0];
    _barGroups = _createBarGroups(initialEmotions);
  }

  @override
  void didUpdateWidget(BarChartTest oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startDate != oldWidget.startDate ||
        widget.endDate != oldWidget.endDate) {
      fetchData();
    }
  }

  void fetchData() async {
    String formStartDate = formatDate(widget.startDate);
    String formEndDate = formatDate(widget.endDate);
    try {
      var response = await _apiService.post('/api/diary/list/period', data: {
        "startDate": formStartDate,
        "endDate": formEndDate,
      });

      var jsonData = response.data;

      List<int> emotions = [];

      if (jsonData is List) {
        var modelList = jsonData.map((item) {
          if (item is Map<String, dynamic>) {
            return AnalysisModel.fromJson(item);
          } else {
            debugPrint('Item is not a Map: $item');
            throw Exception("Item is not a Map");
          }
        }).toList();
        if (modelList.isNotEmpty) {
          emotions = [
            modelList.map((m) => m.diaryHappiness).reduce((a, b) => a + b) ~/
                modelList.length,
            modelList.map((m) => m.diarySadness).reduce((a, b) => a + b) ~/
                modelList.length,
            modelList.map((m) => m.diaryFear).reduce((a, b) => a + b) ~/
                modelList.length,
            modelList.map((m) => m.diaryAnger).reduce((a, b) => a + b) ~/
                modelList.length,
            modelList.map((m) => m.diarySurprise).reduce((a, b) => a + b) ~/
                modelList.length,
          ];
        } else {
          emotions = [0, 0, 0, 0, 0]; // 모든 감정값을 0으로 초기화
        }
      } else {
        debugPrint('Data is not a list: $jsonData');
        throw Exception("Received data is neither a Map nor a List");
      }

      _barGroups = _createBarGroups(emotions);

      setState(() {});
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  List<BarChartGroupData> _createBarGroups(List<int> values) {
    const colors = [
      Color(0xff845EC2),
      Color(0xffD65DB1),
      Color(0xffFF6F91),
      Color(0xffFF9671),
      Color(0xffFFC75F),
    ];

    return List.generate(values.length, (index) {
      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(
          toY: values[index].toDouble(),
          color: colors[index],
          width: 20,
          borderRadius: BorderRadius.zero,
        )
      ]);
    });
  }

  BarTouchData _createBarTouchData() => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.white,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItem: (group, groupIndex, rod, _) {
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
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: _barGroups.isNotEmpty ? _barGroups : [],
        barTouchData: _createBarTouchData(),
        titlesData: const FlTitlesData(show: false),
      ),
      swapAnimationDuration: const Duration(milliseconds: 500),
      swapAnimationCurve: Curves.linear,
    );
  }
}
