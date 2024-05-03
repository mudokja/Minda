import 'dart:math';

import 'package:diary_fe/src/chart/bar_chart/bar_chart_test.dart';
import 'package:diary_fe/src/chart/line_chart/line_chart.dart';
import 'package:diary_fe/src/chart/radar_chart/radar_chart_test.dart';
import 'package:diary_fe/src/models/advice_model.dart';
import 'package:diary_fe/src/services/advice_service.dart';
import 'package:diary_fe/src/services/analysis_service.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';

class DayAnalysisPage extends StatefulWidget {
  const DayAnalysisPage({super.key});

  @override
  State<DayAnalysisPage> createState() => _DayAnalysisPageState();
}

class _DayAnalysisPageState extends State<DayAnalysisPage> {
  DateTime date = DateTime.now();
  late AnalysisService _analysisService;
  late AdviceService _adviceService;
  Map<String, dynamic> analysisData = {};
  AdviceModel? advice;

  String formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _analysisService = AnalysisService();
    _adviceService = AdviceService();
    fetchAnalysisData();
  }

  void fetchAnalysisData() async {
    debugPrint('됨 1');
    var data = await _analysisService.fetchData(date, date);
    debugPrint('됨 2');

    try {
      var adviceData = await _adviceService.fetchAdvice(date);
      debugPrint('됨 3');

      setState(() {
        analysisData = data;
        advice = adviceData;
        debugPrint('analysisData = $analysisData');
        debugPrint('advice = $advice');
      });
    } catch (e) {
      debugPrint("Error fetching advice: $e");
      setState(() {
        analysisData = data;
      });
    }
  }

  Map<String, Color> emotionColors = {
    '기쁨': const Color(0xff845EC2),
    '슬픔': const Color(0xffD65DB1),
    '분노': const Color(0xffFF6F91),
    '불안': const Color(0xffFF9671),
    '놀람': const Color(0xffFFC75F),
  };

  void onChangeDate(int num) {
    setState(() {
      if (num > 0) {
        if (date.isBefore(DateTime.now())) {
          DateTime newDate = date.add(Duration(days: num));
          date = newDate.isBefore(DateTime.now()) ||
                  newDate.isAtSameMomentAs(DateTime.now())
              ? newDate
              : DateTime.now();
        }
      } else if (num < 0) {
        date = date.subtract(Duration(days: (-num)));
      }
      fetchAnalysisData();
    });
  }

  void fetchDummyData() async {
    final ApiService apiService = ApiService();
    await apiService.get('/api/diary/dummy');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<TextSpan> spans = [];

    if (advice != null &&
        analysisData.containsKey('contents') &&
        analysisData['contents'].isNotEmpty) {
      String content = analysisData['contents'][0];
      List<String> sentences = advice!.sentences;
      List<String> emotions = advice!.emotions;

      int currentIndex = 0;
      for (int i = 0; i < min(sentences.length, emotions.length); i++) {
        String sentence = sentences[i];
        String emotion = emotions[i];

        int startIndex = content.indexOf(sentence, currentIndex);
        if (startIndex != -1) {
          if (startIndex > currentIndex) {
            spans.add(TextSpan(
              text: content.substring(currentIndex, startIndex),
              style: const TextStyle(color: Colors.white),
            ));
          }

          spans.add(TextSpan(
            text: sentence,
            style: TextStyle(
              color: Colors.white,
              backgroundColor: emotionColors[emotion] ?? Colors.grey,
            ),
          ));

          currentIndex = startIndex + sentence.length;
        }
      }

      if (currentIndex < content.length) {
        spans.add(TextSpan(
          text: content.substring(currentIndex),
          style: const TextStyle(color: Colors.white),
        ));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onChangeDate(-1),
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
              ),
              TextButton(
                onPressed: () async {
                  final DateTime? dateTime = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (dateTime != null) {
                    setState(() {
                      date = dateTime;
                      fetchAnalysisData();
                    });
                  }
                },
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith(
                    (states) {
                      return Colors.white;
                    },
                  ),
                  overlayColor: MaterialStateProperty.resolveWith(
                    (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.transparent;
                      }
                      return null;
                    },
                  ),
                ),
                child: Text(
                  '${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onChangeDate(1),
                icon: const Icon(Icons.arrow_forward_ios),
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(
            width: screenWidth,
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.transparent,
                  child: Text(
                    analysisData['titles'] != null &&
                            analysisData['titles'].isNotEmpty
                        ? '${analysisData['titles'][0]}'
                        : '현재 작성된 일기가 없습니다!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (analysisData['contents'] != null &&
                    analysisData['contents'].isNotEmpty)
                  Container(
                    color: Colors.transparent,
                    child: RichText(
                      text: TextSpan(
                        children: spans,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 18,
            child: TextButton(
              onPressed: fetchDummyData,
              child: const Text('더미 데이터 생성'),
            ),
          ),
          const Text(
            '일기 분석',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: screenWidth / 2.5,
                height: 200,
                child: BarChartTest(
                  emotions: analysisData['emotions'] != null &&
                          analysisData['emotions'].containsKey(formatDate(date))
                      ? analysisData['emotions'][formatDate(date)]
                      : [0, 0, 0, 0, 0],
                ),
              ),
              SizedBox(
                width: screenWidth / 2.5,
                height: 200,
                child: RadarChartTest(
                  emotions: analysisData['emotions'] != null &&
                          analysisData['emotions'].containsKey(formatDate(date))
                      ? analysisData['emotions'][formatDate(date)]
                      : [0, 0, 0, 0, 0],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Image.asset(
                  'assets/gifs/thinking_face.gif',
                  width: 100,
                  height: 100,
                ),
              ),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 5,
                child: SizedBox(
                  child: RichText(
                    text: TextSpan(
                      children: spans,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class WeekAnalysisPage extends StatefulWidget {
  const WeekAnalysisPage({super.key});

  @override
  State<WeekAnalysisPage> createState() => _WeekAnalysisPageState();
}

class _WeekAnalysisPageState extends State<WeekAnalysisPage> {
  DateTimeRange? dateRange;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime endDate = DateTime.now();
  late AnalysisService _analysisService;
  Map<String, dynamic> analysisData = {};

  @override
  void initState() {
    super.initState();
    _analysisService = AnalysisService();
    dateRange = DateTimeRange(
      start: startDate,
      end: endDate,
    );
    fetchAnalysisData();
  }

  void fetchAnalysisData() async {
    var data = await _analysisService.fetchData(startDate, endDate);

    setState(() {
      analysisData = data;
    });
  }

  void onChangeDate(int numWeeks) {
    setState(() {
      if (numWeeks > 0) {
        DateTime newDate = startDate.add(Duration(days: 7 * numWeeks));
        if (newDate.isBefore(DateTime.now())) {
          startDate =
              newDate.isBefore(DateTime.now()) ? newDate : DateTime.now();
        }
      } else if (numWeeks < 0) {
        startDate = startDate.subtract(Duration(days: 7 * (-numWeeks)));
      }
      endDate = startDate.add(const Duration(days: 6));

      dateRange = DateTimeRange(start: startDate, end: endDate);
    });
    fetchAnalysisData();
  }

  void selectWeek(BuildContext context) async {
    final DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      saveText: '확인',
    );
    if (newDateRange != null && newDateRange.duration.inDays == 6) {
      setState(() {
        dateRange = newDateRange;
        startDate = dateRange!.start;
        endDate = dateRange!.end;
      });
      fetchAnalysisData();
    }
    // else {
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: const Text('경고'),
    //         content: const Text('일주일 간격으로 해라.'),
    //         actions: [
    //           TextButton(
    //             onPressed: () => Navigator.pop(context),
    //             child: const Text('ㅇㅇ'),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onChangeDate(-1),
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
              ),
              TextButton(
                onPressed: () => selectWeek(context),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith(
                    (states) {
                      return Colors.white;
                    },
                  ),
                  overlayColor: MaterialStateProperty.resolveWith(
                    (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.transparent;
                      }
                      return null;
                    },
                  ),
                ),
                child: Text(
                  '${dateRange!.start.year.toString()}-${dateRange!.start.month.toString().padLeft(2, '0')}-${dateRange!.start.day.toString().padLeft(2, '0')}~${dateRange!.end.year.toString()}-${dateRange!.end.month.toString().padLeft(2, '0')}-${dateRange!.end.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onChangeDate(1),
                icon: const Icon(Icons.arrow_forward_ios),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            width: screenWidth,
            height: 200,
            child: LineChartTest(
              emotionsData: analysisData['emotions'] ?? {},
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          const Text(
            '주간일기 분석',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Image.asset(
                  'assets/gifs/thinking_face.gif',
                  width: 100,
                  height: 100,
                ),
              ),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 5,
                child: SizedBox(
                  child: Text(
                    '${analysisData['emotions']}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class MonthAnalysisPage extends StatefulWidget {
  const MonthAnalysisPage({super.key});

  @override
  State<MonthAnalysisPage> createState() => _MonthAnalysisPageState();
}

class _MonthAnalysisPageState extends State<MonthAnalysisPage> {
  DateTime date = DateTime.now();
  late AnalysisService _analysisService;
  Map<String, dynamic> analysisData = {};

  @override
  void initState() {
    super.initState();
    _analysisService = AnalysisService();
  }

  void fetchAnalysisData() async {
    DateTime startDate = DateTime(date.year, date.month, 1);
    DateTime endDate = DateTime(date.year, date.month + 1, 0);

    if (date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      endDate = DateTime.now();
    }

    var data = await _analysisService.fetchData(startDate, endDate);

    setState(() {
      analysisData = data;
    });
  }

  void onChangeDate(int numMonths) {
    setState(() {
      int newYear = date.year;
      int newMonth = date.month + numMonths;

      if (newMonth > 12) {
        newYear += (newMonth - 1) ~/ 12;
        newMonth = (newMonth - 1) % 12 + 1;
      } else if (newMonth < 1) {
        newYear += (newMonth - 12) ~/ 12;
        newMonth = 12 + (newMonth % 12);
      }

      DateTime newDate = DateTime(newYear, newMonth, 1);

      if (newDate.isAfter(DateTime.now())) {
        newDate = DateTime.now();
      }

      date = newDate;
    });
    fetchAnalysisData();
  }

  void selectMonth(BuildContext context) async {
    final DateTime? dateTime = await showMonthPicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (dateTime != null && dateTime != date) {
      setState(() {
        date = DateTime(dateTime.year, dateTime.month);
        fetchAnalysisData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onChangeDate(-1),
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
              ),
              TextButton(
                onPressed: () => selectMonth(context),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith(
                    (states) {
                      return Colors.white;
                    },
                  ),
                  overlayColor: MaterialStateProperty.resolveWith(
                    (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.transparent;
                      }
                      return null;
                    },
                  ),
                ),
                child: Text(
                  '${date.year}-${date.month.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onChangeDate(1),
                icon: const Icon(Icons.arrow_forward_ios),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            width: screenWidth,
            height: 200,
            child: LineChartTest(
              emotionsData: analysisData['emotions'] ?? {},
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAnalysisPage extends StatefulWidget {
  const CustomAnalysisPage({super.key});

  @override
  State<CustomAnalysisPage> createState() => _CustomAnalysisPageState();
}

class _CustomAnalysisPageState extends State<CustomAnalysisPage> {
  DateTimeRange? dateRange;
  late AnalysisService _analysisService;
  Map<String, dynamic> analysisData = {};

  @override
  void initState() {
    super.initState();
    _analysisService = AnalysisService();
  }

  void fetchAnalysisData() async {
    if (dateRange == null) return;

    var data =
        await _analysisService.fetchData(dateRange!.start, dateRange!.end);

    setState(() {
      analysisData = data;
    });
  }

  void selectCustomRange(BuildContext context) async {
    final DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      saveText: '확인',
    );
    if (newDateRange != null && newDateRange != dateRange) {
      setState(() {
        dateRange = newDateRange;
      });
      fetchAnalysisData();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => selectCustomRange(context),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith(
                    (states) {
                      return Colors.white;
                    },
                  ),
                  overlayColor: MaterialStateProperty.resolveWith(
                    (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.transparent;
                      }
                      return null;
                    },
                  ),
                ),
                child: Text(
                  dateRange == null
                      ? '날짜 범위를 선택해주세요.'
                      : '${dateRange!.start.year.toString()}-${dateRange!.start.month.toString().padLeft(2, '0')}-${dateRange!.start.day.toString().padLeft(2, '0')}~${dateRange!.end.year.toString()}-${dateRange!.end.month.toString().padLeft(2, '0')}-${dateRange!.end.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            width: screenWidth,
            height: 200,
            child: LineChartTest(
              emotionsData: analysisData['emotions'] ?? {},
            ),
          ),
        ],
      ),
    );
  }
}
