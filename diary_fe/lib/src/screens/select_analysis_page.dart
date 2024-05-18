import 'dart:async';
import 'dart:convert';
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
  String _loadingText = '현재 일기를 \n분석하고 있습니다';
  int limitedTime = 0;
  Timer? _loadingTimer;
  Timer? _adviceLoadingTimer;
  List<TextSpan> spans = [];
  final String _beforeAdvice = "조언을 생성하는 중입니다. 분석 완료 알림이 오면 다시 확인해주세요.";

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
    _startLoadingAnimation();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopLoadingAnimation();
    _stopAdviceLoadingAnimation();
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
            spans = _generateSpans();
            if (spans.isEmpty) {
              _startLoadingAnimation();
            } else if (advice?.adviceContent == _beforeAdvice) {
              _startAdviceLoadingAnimation();
            }
          });
        }
      } catch (e) {
        debugPrint("Error fetching advice: $e");
        if (mounted) {
          setState(() {
            analysisData = data;
            _isLoading = false;
            spans = _generateSpans();
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          analysisData = data;
          advice = null;
          _isLoading = false;
          spans = [];
        });
      }
    }
  }

  List<TextSpan> _generateSpans() {
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
                    child: emotion != '중립'
                        ? Text(
                            sentence,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Stack(
                            children: <Widget>[
                              Text(
                                sentence,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 1.5
                                    ..color = Colors.black,
                                ),
                              ),
                              Text(
                                sentence,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )),
              ),
              const WidgetSpan(
                  child: SizedBox(
                height: 34,
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

    return spans;
  }

  Map<String, Color> emotionColors = {
    '기쁨': const Color(0xFFF5AC25),
    '슬픔': const Color(0xFFBC7FCD),
    '분노': const Color(0xFFDF1E1E),
    '불안': const Color(0xFF86469C),
    '놀람': const Color(0xFFFC819E),
  };

  void onChangeDate(int num) {
    setState(() {
      if (num > 0) {
        if (date.isBefore(DateTime.now())) {
          DateTime newDate = date.add(Duration(days: num));
          if (newDate.isBefore(DateTime.now()) ||
              newDate.isAtSameMomentAs(DateTime.now())) {
            date = newDate;
            fetchAnalysisData();
          } else {
            date = DateTime.now();
          }
        }
      } else if (num < 0) {
        date = date.subtract(Duration(days: (-num)));
        fetchAnalysisData();
      }
      widget.onDateSelected(date);
      limitedTime = 0;
      _loadingText = '현재 일기를 \n분석하고 있습니다';
    });
  }

  void _startLoadingAnimation() {
    _loadingTimer ??=
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        if (limitedTime < 20) {
          setState(() {
            if (_loadingText != '현재 일기를 \n분석하고 있습니다...!') {
              _loadingText += '.';
              if (_loadingText == '현재 일기를 \n분석하고 있습니다....') {
                _loadingText = '현재 일기를 \n분석하고 있습니다...!';
              }
            } else {
              fetchAnalysisData();
              limitedTime++;

              _loadingText = '현재 일기를 \n분석하고 있습니다';
            }
          });
        }
      }

      if (spans.isNotEmpty || !mounted || limitedTime >= 20) {
        _stopLoadingAnimation();
      }
    });
  }

  void _stopLoadingAnimation() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
  }

  void _startAdviceLoadingAnimation() {
    _adviceLoadingTimer ??= Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        if (advice?.adviceContent == _beforeAdvice) {
          fetchAnalysisData();
        } else {
          _stopAdviceLoadingAnimation();
        }
      }
    });
  }

  void _stopAdviceLoadingAnimation() {
    _adviceLoadingTimer?.cancel();
    _adviceLoadingTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontTitle = screenWidth < 400 ? 16.0 : 20.0;

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
                    color: const Color(0xFFF9D1DD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(
                    painter: LinedPaperPainter(),
                    foregroundPainter: NotebookHolesPainter(24),
                    child: SizedBox(
                      width: screenWidth,
                      height: 400,
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
                                style: TextStyle(
                                  fontSize: fontTitle,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              analysisData['contents'] != null &&
                                      analysisData['contents'].isNotEmpty
                                  ? spans.isNotEmpty
                                      ? RichText(
                                          text: TextSpan(
                                            children: spans,
                                          ),
                                        )
                                      : limitedTime >= 20
                                          ? Center(
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.restart_alt),
                                                iconSize: 50,
                                                color: Colors.black,
                                                onPressed: () {
                                                  setState(() {
                                                    limitedTime = 0;
                                                    fetchAnalysisData();
                                                  });
                                                },
                                              ),
                                            )
                                          : Text(
                                              _loadingText,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                  : const Text('')
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.8,
                  height: 25,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: emotionColors.entries.map((entry) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: entry.value.withOpacity(0.7),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth < 400 ? 13 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                analysisData['titles'] != null &&
                        analysisData['titles'].isNotEmpty
                    ? Column(
                        children: [
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
                                          analysisData['emotions']
                                              [formatDate(date)])
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
                                          analysisData['emotions']
                                              [formatDate(date)])
                                      : [0.0, 0.0, 0.0, 0.0, 0.0],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          spans.isNotEmpty
                              ? Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                                : Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        )),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20.0),
                                                      child: Stack(
                                                        children: <Widget>[
                                                          Text(
                                                            '${advice!.adviceContent}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              foreground:
                                                                  Paint()
                                                                    ..style =
                                                                        PaintingStyle
                                                                            .stroke
                                                                    ..strokeWidth =
                                                                        3
                                                                    ..color =
                                                                        Colors
                                                                            .white,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${advice!.adviceContent}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              : const Text('')
                        ],
                      )
                    : const Text(''),
                const SizedBox(
                  height: 20,
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
  late AdviceService adviceService;
  Map<String, dynamic> analysisData = {};
  Map<String, String>? adviceData;
  String? happiestDate;
  String? happiestKeyword;
  String? saddestDate;
  String? saddestKeyword;
  bool _isLoading = true;
  bool _isDisposed = false;
  Timer? _adviceLoadingTimer;
  String _loadingText = '현재 주간 일기를 \n분석하고 있습니다';
  bool _isAdviceLoading = true;
  int limitedTime = 0;

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
    _startAdviceLoadingAnimation();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopAdviceLoadingAnimation();
    super.dispose();
  }

  Future<void> fetchAnalysisData() async {
    if (_isDisposed) return;

    var data = await analysisService.fetchData(startDate, endDate);

    if (data['emotions'].isNotEmpty) {
      setState(() {
        analysisData = data;
        _isLoading = false;
        _isAdviceLoading = true;
        _startAdviceLoadingAnimation();
        findHighestEmotionDates();
      });

      try {
        var adviceMap =
            await adviceService.fetchAdviceByDateRange(startDate, endDate);
        if (mounted) {
          setState(() {
            adviceData = adviceMap;
            _isAdviceLoading = false;
            _stopAdviceLoadingAnimation();
          });
        }
      } catch (e) {
        debugPrint("Error fetching advice: $e");
        if (mounted) {
          setState(() {
            _isAdviceLoading = false;
            _stopAdviceLoadingAnimation();
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          analysisData = data;
          _isLoading = false;
          _isAdviceLoading = false;
        });
      }
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
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
          fetchAnalysisData();
        }
      } else if (numWeeks < 0) {
        startDate = startDate.subtract(Duration(days: 7 * (-numWeeks)));
        endDate = startDate.add(const Duration(days: 6));
        fetchAnalysisData();
      }

      dateRange = DateTimeRange(start: startDate, end: endDate);
      _loadingText = '현재 주간 일기를 \n분석하고 있습니다';
      limitedTime = 0;
    });
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
  }

  Map<String, Color> emotionColors = {
    '기쁨': const Color(0xFFF5AC25),
    '슬픔': const Color(0xFFBC7FCD),
    '분노': const Color(0xFFDF1E1E),
    '불안': const Color(0xFF86469C),
    '놀람': const Color(0xFFFC819E),
  };

  void _startAdviceLoadingAnimation() {
    _adviceLoadingTimer?.cancel();
    _adviceLoadingTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          if (_loadingText != '현재 주간 일기를 \n분석하고 있습니다...!') {
            _loadingText += '.';
            if (_loadingText == '현재 주간 일기를 \n분석하고 있습니다....') {
              _loadingText = '현재 주간 일기를 \n분석하고 있습니다...!';
            }
          }
        });
      }
    });
  }

  void _stopAdviceLoadingAnimation() {
    _adviceLoadingTimer?.cancel();
    _adviceLoadingTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final fontTitle = screenWidth < 400 ? 16.0 : 20.0;

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
                        style: TextStyle(
                          fontSize: fontTitle,
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
                  Column(
                    children: [
                      if (singleEntry)
                        Column(
                          children: [
                            SizedBox(
                              width: screenWidth / 2.5,
                              height: 200,
                              child: BarChartTest(
                                emotions: List<double>.from(
                                    analysisData['emotions']
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
                        ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: screenWidth * 0.8,
                        height: 25,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: emotionColors.entries.map((entry) {
                            return Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: entry.value.withOpacity(0.7),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      entry.key,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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
                analysisData['titles'] != null &&
                        analysisData['titles'].isNotEmpty
                    ? Column(
                        children: [
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
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      )),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Stack(
                                      children: <Widget>[
                                        Text(
                                          _isAdviceLoading
                                              ? _loadingText
                                              : adviceData != null
                                                  ? adviceData![
                                                      'adviceContent']!
                                                  : '분석에 실패했습니다. 다시 시도해주세요.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            foreground: Paint()
                                              ..style = PaintingStyle.stroke
                                              ..strokeWidth = 3
                                              ..color = Colors.white,
                                          ),
                                        ),
                                        Text(
                                          _isAdviceLoading
                                              ? _loadingText
                                              : adviceData != null
                                                  ? adviceData![
                                                      'adviceContent']!
                                                  : '분석에 실패했습니다. 다시 시도해주세요.',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          if (adviceData?['imageLink'] != null)
                            Image.network(
                              adviceData!['imageLink']!,
                              width: 200,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text('이미지를 불러올 수 없습니다.');
                              },
                            ),
                        ],
                      )
                    : const Text(''),
                const SizedBox(
                  height: 50,
                ),
                if (hasEmotions)
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
                else
                  const Text('')
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
  late AdviceService adviceService;
  Map<String, dynamic> analysisData = {};
  Map<String, String>? adviceData;
  String? happiestDate;
  String? happiestKeyword;
  String? saddestDate;
  String? saddestKeyword;
  bool _isLoading = true;
  bool _isDisposed = false;
  Timer? _adviceLoadingTimer;
  String _loadingText = '현재 월간 일기를 \n분석하고 있습니다';
  bool _isAdviceLoading = true;
  int limitedTime = 0;

  @override
  void initState() {
    super.initState();
    analysisService = AnalysisService();
    adviceService = AdviceService();
    fetchAnalysisData();
    _startAdviceLoadingAnimation();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopAdviceLoadingAnimation();
    super.dispose();
  }

  Future<void> fetchAnalysisData() async {
    if (_isDisposed) return;

    var data = await analysisService.fetchData(startDate, endDate);

    if (data['emotions'].isNotEmpty) {
      setState(() {
        analysisData = data;
        _isLoading = false;
        _isAdviceLoading = true;
        _startAdviceLoadingAnimation();
        findHighestEmotionDates();
      });

      try {
        var adviceMap =
            await adviceService.fetchAdviceByDateRange(startDate, endDate);
        if (mounted) {
          setState(() {
            adviceData = adviceMap;
            _isAdviceLoading = false;
            _stopAdviceLoadingAnimation();
          });
        }
      } catch (e) {
        debugPrint("Error fetching advice: $e");
        if (mounted) {
          setState(() {
            _isAdviceLoading = false;
            _stopAdviceLoadingAnimation();
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          analysisData = data;
          _isLoading = false;
          _isAdviceLoading = false;
        });
      }
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
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void onChangeDate(int numMonths) {
    if (_isDisposed) return;

    setState(() {
      if (numMonths > 0) {
        DateTime newStartDate =
            DateTime(startDate.year, startDate.month + numMonths, 1);
        DateTime newEndDate =
            DateTime(newStartDate.year, newStartDate.month + 1, 0);

        if (newEndDate.isAfter(
            DateTime(DateTime.now().year, DateTime.now().month + 1, 0))) {
          endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
          startDate = DateTime(endDate.year, endDate.month, 1);
        } else {
          startDate = newStartDate;
          endDate = newEndDate;
          fetchAnalysisData();
        }
      } else if (numMonths < 0) {
        startDate = DateTime(startDate.year, startDate.month + numMonths, 1);
        endDate = DateTime(startDate.year, startDate.month + 1, 0);
        fetchAnalysisData();
      }

      _loadingText = '현재 월간 일기를 \n분석하고 있습니다';
      limitedTime = 0;
    });
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

  Map<String, Color> emotionColors = {
    '기쁨': const Color(0xFFF5AC25),
    '슬픔': const Color(0xFFBC7FCD),
    '분노': const Color(0xFFDF1E1E),
    '불안': const Color(0xFF86469C),
    '놀람': const Color(0xFFFC819E),
  };

  void _startAdviceLoadingAnimation() {
    _adviceLoadingTimer?.cancel();
    _adviceLoadingTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          if (_loadingText != '현재 월간 일기를 \n분석하고 있습니다...!') {
            _loadingText += '.';
            if (_loadingText == '현재 월간 일기를 \n분석하고 있습니다....') {
              _loadingText = '현재 월간 일기를 \n분석하고 있습니다...!';
            }
          }
        });
      }
    });
  }

  void _stopAdviceLoadingAnimation() {
    _adviceLoadingTimer?.cancel();
    _adviceLoadingTimer = null;
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
                  Column(
                    children: [
                      if (singleEntry)
                        Column(
                          children: [
                            SizedBox(
                              width: screenWidth / 2.5,
                              height: 200,
                              child: BarChartTest(
                                emotions: List<double>.from(
                                    analysisData['emotions']
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
                        ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: screenWidth * 0.8,
                        height: 25,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: emotionColors.entries.map((entry) {
                            return Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: entry.value.withOpacity(0.7),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      entry.key,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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
                analysisData['titles'] != null &&
                        analysisData['titles'].isNotEmpty
                    ? Column(
                        children: [
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
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      )),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Stack(
                                      children: <Widget>[
                                        Text(
                                          _isAdviceLoading
                                              ? _loadingText
                                              : adviceData != null
                                                  ? adviceData![
                                                      'adviceContent']!
                                                  : '분석에 실패했습니다. 다시 시도해주세요.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            foreground: Paint()
                                              ..style = PaintingStyle.stroke
                                              ..strokeWidth = 3
                                              ..color = Colors.white,
                                          ),
                                        ),
                                        Text(
                                          _isAdviceLoading
                                              ? _loadingText
                                              : adviceData != null
                                                  ? adviceData![
                                                      'adviceContent']!
                                                  : '분석에 실패했습니다. 다시 시도해주세요.',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          if (adviceData?['imageLink'] != null)
                            Image.network(
                              adviceData!['imageLink']!,
                              width: 200,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text('이미지를 불러올 수 없습니다.');
                              },
                            ),
                        ],
                      )
                    : const Text(''),
                const SizedBox(
                  height: 50,
                ),
                if (hasEmotions)
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
                else
                  const Text('')
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
  late AdviceService adviceService;
  Map<String, dynamic> analysisData = {};
  Map<String, String>? adviceData;
  String? happiestDate;
  String? happiestKeyword;
  String? saddestDate;
  String? saddestKeyword;
  bool _isLoading = false;
  bool _isDisposed = false;
  Timer? _adviceLoadingTimer;
  String _loadingText = '현재 맞춤 기간 일기를 \n분석하고 있습니다';
  bool _isAdviceLoading = false;
  int limitedTime = 0;

  @override
  void initState() {
    super.initState();
    analysisService = AnalysisService();
    adviceService = AdviceService();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopAdviceLoadingAnimation();
    super.dispose();
  }

  Future<void> fetchAnalysisData() async {
    if (_isDisposed || dateRange == null) return;

    var data =
        await analysisService.fetchData(dateRange!.start, dateRange!.end);

    if (data['emotions'].isNotEmpty) {
      setState(() {
        analysisData = data;
        _isLoading = false;
        _isAdviceLoading = true;
        _startAdviceLoadingAnimation();
        findHighestEmotionDates();
      });

      try {
        var adviceMap = await adviceService.fetchAdviceByDateRange(
            dateRange!.start, dateRange!.end);
        if (mounted) {
          setState(() {
            adviceData = adviceMap;
            _isAdviceLoading = false;
            _stopAdviceLoadingAnimation();
          });
        }
      } catch (e) {
        debugPrint("Error fetching advice: $e");
        if (mounted) {
          setState(() {
            _isAdviceLoading = false;
            _stopAdviceLoadingAnimation();
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          analysisData = data;
          _isLoading = false;
          _isAdviceLoading = false;
        });
      }
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

  Map<String, Color> emotionColors = {
    '기쁨': const Color(0xFFF5AC25),
    '슬픔': const Color(0xFFBC7FCD),
    '분노': const Color(0xFFDF1E1E),
    '불안': const Color(0xFF86469C),
    '놀람': const Color(0xFFFC819E),
  };

  void _startAdviceLoadingAnimation() {
    _adviceLoadingTimer?.cancel();
    _adviceLoadingTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          if (_loadingText != '현재 맞춤 기간 일기를 \n분석하고 있습니다...!') {
            _loadingText += '.';
            if (_loadingText == '현재 맞춤 기간 일기를 \n분석하고 있습니다....') {
              _loadingText = '현재 맞춤 기간 일기를 \n분석하고 있습니다...!';
            }
          }
        });
      }
    });
  }

  void _stopAdviceLoadingAnimation() {
    _adviceLoadingTimer?.cancel();
    _adviceLoadingTimer = null;
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
                  Column(
                    children: [
                      if (singleEntry)
                        Column(
                          children: [
                            SizedBox(
                              width: screenWidth / 2.5,
                              height: 200,
                              child: BarChartTest(
                                emotions: List<double>.from(
                                    analysisData['emotions']
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
                        ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: screenWidth * 0.8,
                        height: 25,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: emotionColors.entries.map((entry) {
                            return Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: entry.value.withOpacity(0.7),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      entry.key,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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
                    : analysisData['titles'] != null &&
                            analysisData['titles'].isNotEmpty
                        ? Column(
                            children: [
                              const Text(
                                '맞춤 기간 일기 분석',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          )),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Stack(
                                          children: <Widget>[
                                            Text(
                                              _isAdviceLoading
                                                  ? _loadingText
                                                  : adviceData != null
                                                      ? adviceData![
                                                          'adviceContent']!
                                                      : '분석에 실패했습니다. 다시 시도해주세요.',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                foreground: Paint()
                                                  ..style = PaintingStyle.stroke
                                                  ..strokeWidth = 3
                                                  ..color = Colors.white,
                                              ),
                                            ),
                                            Text(
                                              _isAdviceLoading
                                                  ? _loadingText
                                                  : adviceData != null
                                                      ? adviceData![
                                                          'adviceContent']!
                                                      : '분석에 실패했습니다. 다시 시도해주세요.',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              if (adviceData?['imageLink'] != null)
                                Image.network(
                                  adviceData!['imageLink']!,
                                  width: 200,
                                  height: 200,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text('이미지를 불러올 수 없습니다.');
                                  },
                                ),
                            ],
                          )
                        : const Text(''),
                const SizedBox(
                  height: 50,
                ),
                dateRange == null
                    ? const Text('')
                    : hasEmotions
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (happiestDate != null &&
                                  happiestKeyword != null)
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
                        : const Text('')
              ],
            ),
          );
  }
}
