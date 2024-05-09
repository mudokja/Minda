import 'dart:math';

import 'package:diary_fe/src/chart/bar_chart/bar_chart_test.dart';
import 'package:diary_fe/src/chart/line_chart/line_chart.dart';
import 'package:diary_fe/src/chart/radar_chart/radar_chart_test.dart';
import 'package:diary_fe/src/models/advice_model.dart';
import 'package:diary_fe/src/screens/diary_detail_page.dart';
import 'package:diary_fe/src/services/advice_service.dart';
import 'package:diary_fe/src/services/analysis_service.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';

class DayAnalysisPage extends StatefulWidget {
  final DateTime date;
  final Function(DateTime) onDateSelected;

  const DayAnalysisPage({
    super.key,
    required this.date,
    required this.onDateSelected,
  });

  @override
  State<DayAnalysisPage> createState() => _DayAnalysisPageState();
}

class _DayAnalysisPageState extends State<DayAnalysisPage> {
  late DateTime date;
  late AnalysisService _analysisService;
  late AdviceService _adviceService;
  Map<String, dynamic> analysisData = {};
  AdviceModel? advice;
  bool _isLoading = true;
  bool _isDisposed = false;

  String formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    date = widget.date;
    _analysisService = AnalysisService();
    _adviceService = AdviceService();
    fetchAnalysisData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchAnalysisData() async {
    if (_isDisposed) return;

    var data = await _analysisService.fetchData(date, date);

    if (data['contents'].isNotEmpty) {
      try {
        var adviceData = await _adviceService.fetchAdvice(date);

        if (mounted) {
          setState(() {
            _isLoading = false;
            analysisData = data;
            advice = adviceData;
          });
        }
      } catch (e) {
        debugPrint("Error fetching advice: $e");
        if (mounted) {
          setState(() {
            analysisData = data;
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          analysisData = data;
          advice = null;
          _isLoading = false;
        });
      }
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
      widget.onDateSelected(date);
      fetchAnalysisData();
    });
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
            children: [
              WidgetSpan(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: emotionColors[emotion]?.withOpacity(0.7) ??
                        Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sentence,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const WidgetSpan(
                  child: SizedBox(
                height: 40,
              ))
            ],
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
    return _isLoading
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          )
        : Padding(
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
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9D1DD), // Pink background color
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: CustomPaint(
                    painter: LinedPaperPainter(),
                    foregroundPainter: NotebookHolesPainter(
                        24), // Line spacing for notebook holes
                    child: SizedBox(
                      width: screenWidth,
                      height: 400, // Fixed height
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                analysisData['titles'] != null &&
                                        analysisData['titles'].isNotEmpty
                                    ? '${analysisData['titles'][0]}'
                                    : '현재 작성된 일기가 없습니다!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (analysisData['contents'] != null &&
                                  analysisData['contents'].isNotEmpty)
                                RichText(
                                  text: TextSpan(
                                    children: spans,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 18,
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
                                analysisData['emotions']
                                    .containsKey(formatDate(date))
                            ? List<double>.from(
                                analysisData['emotions'][formatDate(date)])
                            : [0.0, 0.0, 0.0, 0.0, 0.0],
                      ),
                    ),
                    SizedBox(
                      width: screenWidth / 2.5,
                      height: 200,
                      child: RadarChartTest(
                        emotions: analysisData['emotions'] != null &&
                                analysisData['emotions']
                                    .containsKey(formatDate(date))
                            ? List<double>.from(
                                analysisData['emotions'][formatDate(date)])
                            : [0.0, 0.0, 0.0, 0.0, 0.0],
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
                          child: advice?.adviceContent == null
                              ? const Text('')
                              : Text('${advice!.adviceContent}')),
                    )
                  ],
                )
              ],
            ),
          );
  }
}

class WeekAnalysisPage extends StatefulWidget {
  final Function(DateTime)? onDateSelected;

  const WeekAnalysisPage({
    super.key,
    required this.onDateSelected,
  });

  @override
  State<WeekAnalysisPage> createState() => _WeekAnalysisPageState();
}

class _WeekAnalysisPageState extends State<WeekAnalysisPage> {
  DateTimeRange? dateRange;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime endDate = DateTime.now();
  late AnalysisService analysisService;
  Map<String, dynamic> analysisData = {};
  String? happiestDate;
  String? happiestKeyword;
  String? saddestDate;
  String? saddestKeyword;
  late AdviceService adviceService;
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    analysisService = AnalysisService();
    adviceService = AdviceService();
    dateRange = DateTimeRange(
      start: startDate,
      end: endDate,
    );
    fetchAnalysisData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchAnalysisData() async {
    if (_isDisposed) return;

    var data = await analysisService.fetchData(startDate, endDate);

    if (mounted) {
      setState(() {
        analysisData = data;
        findHighestEmotionDates();
      });
    }
  }

  void navigateToDayAnalysis(DateTime date) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(date);
    } else {
      debugPrint('onDateSelected is null');
    }
  }

  Future<void> findHighestEmotionDates() async {
    if (_isDisposed) return;

    happiestDate = null;
    happiestKeyword = null;
    saddestDate = null;
    saddestKeyword = null;

    analysisData['emotions'].forEach((date, emotions) async {
      if (emotions != null && emotions.length >= 5) {
        final happinessValue = emotions[0];
        final sadnessValue = emotions[1];

        if (happiestDate == null ||
            happinessValue > analysisData['emotions'][happiestDate]![0]) {
          happiestDate = date;
        }

        if (saddestDate == null ||
            sadnessValue > analysisData['emotions'][saddestDate]![1]) {
          saddestDate = date;
        }
      }
    });

    if (happiestDate != null) {
      var advice =
          await adviceService.fetchAdvice(DateTime.parse(happiestDate!));
      if (advice != null && advice.emotions.isNotEmpty) {
        int happyIndex = advice.emotions.indexOf('기쁨');
        if (happyIndex != -1) {
          happiestKeyword = advice.sentences[happyIndex];
        }
      }
    }

    if (saddestDate != null) {
      var advice =
          await adviceService.fetchAdvice(DateTime.parse(saddestDate!));
      if (advice != null && advice.emotions.isNotEmpty && mounted) {
        int sadIndex = advice.emotions.indexOf('슬픔');
        if (sadIndex != -1) {
          saddestKeyword = advice.sentences[sadIndex];
        }
      }
    }
    _isLoading = false;
    setState(() {});
  }

  void onChangeDate(int numWeeks) {
    if (_isDisposed) return;

    setState(() {
      if (numWeeks > 0) {
        DateTime newStartDate = startDate.add(Duration(days: 7 * numWeeks));
        DateTime newEndDate = newStartDate.add(const Duration(days: 6));

        if (newEndDate.isAfter(DateTime.now())) {
          endDate = DateTime.now();
          startDate = endDate.subtract(const Duration(days: 6));
        } else {
          startDate = newStartDate;
          endDate = newEndDate;
        }
      } else if (numWeeks < 0) {
        startDate = startDate.subtract(Duration(days: 7 * (-numWeeks)));
        endDate = startDate.add(const Duration(days: 6));
      }

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
    bool hasEmotions =
        analysisData['emotions'] != null && analysisData['emotions'].isNotEmpty;
    bool singleEntry = hasEmotions && analysisData['emotions'].length == 1;

    return _isLoading
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          )
        : Padding(
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
                if (hasEmotions)
                  if (singleEntry)
                    Column(
                      children: [
                        SizedBox(
                          width: screenWidth / 2.5,
                          height: 200,
                          child: BarChartTest(
                            emotions: List<double>.from(analysisData['emotions']
                                [analysisData['emotions'].keys.first]),
                          ),
                        ),
                        Text(
                          '${analysisData['emotions'].keys.first}에 작성된 감정 분석',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: screenWidth * 0.8,
                      height: 200,
                      child: LineChartTest(
                        emotionsData: analysisData['emotions'],
                      ),
                    )
                else
                  const Text(
                    '이 주에 작성된 일기가 없습니다...',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (happiestDate != null && happiestKeyword != null)
                      GestureDetector(
                        onTap: widget.onDateSelected != null
                            ? () {
                                navigateToDayAnalysis(
                                    DateTime.parse(happiestDate!));
                              }
                            : null,
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            children: [
                              const Text(
                                '가장 행복했던 날',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFBCEBFF),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    Text(
                                      '$happiestDate',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4B6DAD),
                                      ),
                                    ),
                                    Text(
                                      '$happiestKeyword',
                                      style: const TextStyle(
                                        color: Color(0xFF4B6DAD),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Text(''),
                    if (saddestDate != null && saddestKeyword != null)
                      GestureDetector(
                        onTap: widget.onDateSelected != null
                            ? () {
                                navigateToDayAnalysis(
                                    DateTime.parse(saddestDate!));
                              }
                            : null,
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            children: [
                              const Text(
                                '가장 속상했던 날',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFFFC6A6),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    Text(
                                      '$saddestDate',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFDC6868),
                                      ),
                                    ),
                                    Text(
                                      '$saddestKeyword',
                                      style: const TextStyle(
                                        color: Color(0xFFDC6868),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Text(''),
                  ],
                )
              ],
            ),
          );
  }
}

class MonthAnalysisPage extends StatefulWidget {
  final Function(DateTime)? onDateSelected;

  const MonthAnalysisPage({
    super.key,
    required this.onDateSelected,
  });

  @override
  State<MonthAnalysisPage> createState() => _MonthAnalysisPageState();
}

class _MonthAnalysisPageState extends State<MonthAnalysisPage> {
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  late AnalysisService analysisService;
  Map<String, dynamic> analysisData = {};
  String? happiestDate;
  String? happiestKeyword;
  String? saddestDate;
  String? saddestKeyword;
  late AdviceService adviceService;
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    analysisService = AnalysisService();
    adviceService = AdviceService();
    fetchAnalysisData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchAnalysisData() async {
    if (_isDisposed) return;

    var data = await analysisService.fetchData(startDate, endDate);

    if (mounted) {
      setState(() {
        analysisData = data;
        findHighestEmotionDates();
      });
    }
  }

  void navigateToDayAnalysis(DateTime date) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(date);
    } else {
      debugPrint('onDateSelected is null');
    }
  }

  Future<void> findHighestEmotionDates() async {
    if (_isDisposed) return;

    happiestDate = null;
    happiestKeyword = null;
    saddestDate = null;
    saddestKeyword = null;

    analysisData['emotions'].forEach((date, emotions) async {
      if (emotions != null && emotions.length >= 5) {
        final happinessValue = emotions[0];
        final sadnessValue = emotions[1];

        if (happiestDate == null ||
            happinessValue > analysisData['emotions'][happiestDate]![0]) {
          happiestDate = date;
        }

        if (saddestDate == null ||
            sadnessValue > analysisData['emotions'][saddestDate]![1]) {
          saddestDate = date;
        }
      }
    });

    if (happiestDate != null) {
      var advice =
          await adviceService.fetchAdvice(DateTime.parse(happiestDate!));
      if (advice != null && advice.emotions.isNotEmpty) {
        int happyIndex = advice.emotions.indexOf('기쁨');
        if (happyIndex != -1) {
          happiestKeyword = advice.sentences[happyIndex];
        }
      }
    }

    if (saddestDate != null) {
      var advice =
          await adviceService.fetchAdvice(DateTime.parse(saddestDate!));
      if (advice != null && advice.emotions.isNotEmpty && mounted) {
        int sadIndex = advice.emotions.indexOf('슬픔');
        if (sadIndex != -1) {
          saddestKeyword = advice.sentences[sadIndex];
        }
      }
    }
    _isLoading = false;
    setState(() {});
  }

  void onChangeDate(int numMonths) {
    if (_isDisposed) return;

    setState(() {
      DateTime newStartDate =
          DateTime(startDate.year, startDate.month + numMonths, 1);
      DateTime newEndDate =
          DateTime(newStartDate.year, newStartDate.month + 1, 0);

      if (newEndDate.isAfter(DateTime.now())) {
        endDate = DateTime.now();
        startDate = DateTime(endDate.year, endDate.month, 1);
      } else {
        startDate = newStartDate;
        endDate = newEndDate;
      }
    });
    fetchAnalysisData();
  }

  void selectMonth(BuildContext context) async {
    final DateTime? selectedDate = await showMonthPicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        startDate = DateTime(selectedDate.year, selectedDate.month, 1);
        endDate = DateTime(selectedDate.year, selectedDate.month + 1, 0);
      });
      fetchAnalysisData();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool hasEmotions =
        analysisData['emotions'] != null && analysisData['emotions'].isNotEmpty;
    bool singleEntry = hasEmotions && analysisData['emotions'].length == 1;

    return _isLoading
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          )
        : Padding(
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
                        '${startDate.year.toString()}-${startDate.month.toString().padLeft(2, '0')}',
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
                if (hasEmotions)
                  if (singleEntry)
                    Column(
                      children: [
                        SizedBox(
                          width: screenWidth / 2.5,
                          height: 200,
                          child: BarChartTest(
                            emotions: List<double>.from(analysisData['emotions']
                                [analysisData['emotions'].keys.first]),
                          ),
                        ),
                        Text(
                          '${analysisData['emotions'].keys.first}에 작성된 감정 분석',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: screenWidth * 0.8,
                      height: 200,
                      child: LineChartTest(
                        emotionsData: analysisData['emotions'],
                      ),
                    )
                else
                  const Text(
                    '이 달에 작성된 일기가 없습니다...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  '월간일기 분석',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (happiestDate != null && happiestKeyword != null)
                      GestureDetector(
                        onTap: widget.onDateSelected != null
                            ? () {
                                navigateToDayAnalysis(
                                    DateTime.parse(happiestDate!));
                              }
                            : null,
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            children: [
                              const Text(
                                '가장 행복했던 날',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBCEBFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$happiestDate',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4B6DAD),
                                      ),
                                    ),
                                    Text(
                                      '$happiestKeyword',
                                      style: const TextStyle(
                                        color: Color(0xFF4B6DAD),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Text(''),
                    if (saddestDate != null && saddestKeyword != null)
                      GestureDetector(
                        onTap: widget.onDateSelected != null
                            ? () {
                                navigateToDayAnalysis(
                                    DateTime.parse(saddestDate!));
                              }
                            : null,
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            children: [
                              const Text(
                                '가장 속상했던 날',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC6A6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$saddestDate',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFDC6868),
                                      ),
                                    ),
                                    Text(
                                      '$saddestKeyword',
                                      style: const TextStyle(
                                        color: Color(0xFFDC6868),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Text(''),
                  ],
                )
              ],
            ),
          );
  }
}

class CustomAnalysisPage extends StatefulWidget {
  final Function(DateTime)? onDateSelected;

  const CustomAnalysisPage({
    super.key,
    required this.onDateSelected,
  });

  @override
  State<CustomAnalysisPage> createState() => _CustomAnalysisPageState();
}

class _CustomAnalysisPageState extends State<CustomAnalysisPage> {
  DateTimeRange? dateRange;
  late AnalysisService analysisService;
  Map<String, dynamic> analysisData = {};
  String? happiestDate;
  String? happiestKeyword;
  String? saddestDate;
  String? saddestKeyword;
  late AdviceService adviceService;
  bool _isLoading = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    analysisService = AnalysisService();
    adviceService = AdviceService();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchAnalysisData() async {
    if (_isDisposed && dateRange == null) return;

    var data =
        await analysisService.fetchData(dateRange!.start, dateRange!.end);

    if (mounted) {
      setState(() {
        analysisData = data;
        findHighestEmotionDates();
      });
    }
  }

  void navigateToDayAnalysis(DateTime date) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(date);
    } else {
      debugPrint('onDateSelected is null');
    }
  }

  Future<void> findHighestEmotionDates() async {
    if (_isDisposed) return;

    happiestDate = null;
    happiestKeyword = null;
    saddestDate = null;
    saddestKeyword = null;

    analysisData['emotions'].forEach((date, emotions) async {
      if (emotions != null && emotions.length >= 5) {
        final happinessValue = emotions[0];
        final sadnessValue = emotions[1];

        if (happiestDate == null ||
            happinessValue > analysisData['emotions'][happiestDate]![0]) {
          happiestDate = date;
        }

        if (saddestDate == null ||
            sadnessValue > analysisData['emotions'][saddestDate]![1]) {
          saddestDate = date;
        }
      }
    });

    if (happiestDate != null) {
      var advice =
          await adviceService.fetchAdvice(DateTime.parse(happiestDate!));
      if (advice != null && advice.emotions.isNotEmpty) {
        int happyIndex = advice.emotions.indexOf('기쁨');
        if (happyIndex != -1) {
          happiestKeyword = advice.sentences[happyIndex];
        }
      }
    }

    if (saddestDate != null) {
      var advice =
          await adviceService.fetchAdvice(DateTime.parse(saddestDate!));
      if (advice != null && advice.emotions.isNotEmpty && mounted) {
        int sadIndex = advice.emotions.indexOf('슬픔');
        if (sadIndex != -1) {
          saddestKeyword = advice.sentences[sadIndex];
        }
      }
    }
    setState(() {});
    _isLoading = false;
  }

  void selectCustomRange(BuildContext context) async {
    _isLoading = true;
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
    bool hasEmotions =
        analysisData['emotions'] != null && analysisData['emotions'].isNotEmpty;
    bool singleEntry = hasEmotions && analysisData['emotions'].length == 1;

    return _isLoading
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          )
        : Padding(
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
                if (hasEmotions)
                  if (singleEntry)
                    Column(
                      children: [
                        SizedBox(
                          width: screenWidth / 2.5,
                          height: 200,
                          child: BarChartTest(
                            emotions: List<double>.from(analysisData['emotions']
                                [analysisData['emotions'].keys.first]),
                          ),
                        ),
                        Text(
                          '${analysisData['emotions'].keys.first}에 작성된 감정 분석',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: screenWidth * 0.8,
                      height: 200,
                      child: LineChartTest(
                        emotionsData: analysisData['emotions'],
                      ),
                    )
                else
                  dateRange == null
                      ? const Text('')
                      : const Text(
                          '이 기간에 작성된 일기가 없습니다...',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                const SizedBox(
                  height: 50,
                ),
                dateRange == null
                    ? const Text('')
                    : Row(
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
                dateRange == null
                    ? const Text('')
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (happiestDate != null && happiestKeyword != null)
                            GestureDetector(
                              onTap: widget.onDateSelected != null
                                  ? () {
                                      navigateToDayAnalysis(
                                          DateTime.parse(happiestDate!));
                                    }
                                  : null,
                              child: SizedBox(
                                width: 150,
                                child: Column(
                                  children: [
                                    const Text(
                                      '가장 행복했던 날',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFBCEBFF),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        children: [
                                          Text(
                                            '$happiestDate',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF4B6DAD),
                                            ),
                                          ),
                                          Text(
                                            '$happiestKeyword',
                                            style: const TextStyle(
                                              color: Color(0xFF4B6DAD),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const Text(''),
                          if (saddestDate != null && saddestKeyword != null)
                            GestureDetector(
                              onTap: widget.onDateSelected != null
                                  ? () {
                                      navigateToDayAnalysis(
                                          DateTime.parse(saddestDate!));
                                    }
                                  : null,
                              child: SizedBox(
                                width: 150,
                                child: Column(
                                  children: [
                                    const Text(
                                      '가장 속상했던 날',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFFFC6A6),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        children: [
                                          Text(
                                            '$saddestDate',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFDC6868),
                                            ),
                                          ),
                                          Text(
                                            '$saddestKeyword',
                                            style: const TextStyle(
                                              color: Color(0xFFDC6868),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const Text(''),
                        ],
                      )
              ],
            ),
          );
  }
}
