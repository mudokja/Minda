import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:diary_fe/src/models/analysis_model.dart';
import 'package:diary_fe/src/services/api_services.dart';

class RadarChartTest extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const RadarChartTest({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<RadarChartTest> createState() => _RadarChartTestState();
}

class _RadarChartTestState extends State<RadarChartTest> {
  late List<RadarDataSet> _radarDataSets;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeChartData();
    fetchData();
  }

  void _initializeChartData() {
    List<int> initialEmotions = [0, 0, 0, 0, 0];
    _radarDataSets = _createRadarDataSets(initialEmotions);
  }

  @override
  void didUpdateWidget(RadarChartTest oldWidget) {
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
        var modelList =
            jsonData.map((item) => AnalysisModel.fromJson(item)).toList();
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
          _radarDataSets = _createRadarDataSets(emotions);
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  List<RadarDataSet> _createRadarDataSets(List<int> values) {
    return [
      RadarDataSet(
        dataEntries:
            values.map((value) => RadarEntry(value: value.toDouble())).toList(),
        fillColor: Colors.blue.withOpacity(0.3),
        borderColor: Colors.blue,
        borderWidth: 2,
      )
    ];
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
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
