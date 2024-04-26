import 'package:diary_fe/src/widgets/background.dart'; // 이 부분은 실제 경로에 맞게 조정해주세요.
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'dart:math';
// MoodEntry 모델과 getColorFromMood 함수를 import 합니다.
import 'package:diary_fe/src/models/MoodEntry.dart';
import 'package:diary_fe/src/models/MoodEntry.dart' as MoodEntryHelper;
import 'dart:math';

import 'package:table_calendar/table_calendar.dart';

//점선
class DottedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashHeight;
  final Paint dashPaint;

  DottedLinePainter(
      {this.dashWidth = 4.0, this.dashHeight = 1.0, Color color = Colors.black})
      : dashPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = dashHeight;

  @override
  void paint(Canvas canvas, Size size) {
    int dashCount = (size.width / (2 * dashWidth)).floor();
    double startX = 0;
    for (int i = 0; i < dashCount; ++i) {
      canvas.drawLine(
          Offset(startX, 0), Offset(startX + dashWidth, 0), dashPaint);
      startX += 2 * dashWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 달력페이지에서 감정설명부분 토글
class ColorLegendToggle extends StatefulWidget {
  const ColorLegendToggle({super.key});

  @override
  _ColorLegendToggleState createState() => _ColorLegendToggleState();
}

class _ColorLegendToggleState extends State<ColorLegendToggle> {
  bool _showLegend = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _showLegend = !_showLegend; // 토글 상태 변경
            });
          },
          child: Text(
            _showLegend ? '감정 색상 설명 숨기기' : '감정 색상 설명 보기',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_showLegend)
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "●",
                  style: TextStyle(
                    color: Color(0xFFF5AC25), // 기쁨에 노랑
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: " : 기쁨       ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: "●",
                  style: TextStyle(
                    color: Color(0xFFBC7FCD), // 슬픔에 연보라
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: " : 슬픔       ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: "●",
                  style: TextStyle(
                    color: Color(0xFFB3B4B4), // 불안에 회색
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: " : 불안\n",
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: "●",
                  style: TextStyle(
                    color: Color(0xFFDF1E1E), // 분노에 빨강
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: " : 분노       ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: "●",
                  style: TextStyle(
                    color: Color(0xFF86469C), // 상처에 진보라
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: " : 상처       ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: "●",
                  style: TextStyle(
                    color: Color(0xFFFC819E), // 놀람에 핑크
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: " : 놀람",
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLegendItem(String emotion, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          emotion,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

// class DiaryListPage extends StatelessWidget {
//   const DiaryListPage({super.key});

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  _DiaryListPageState createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  // 가상의 일기 데이터
  List<String> diaryEntries = [
    "2024-04-01\n2024년 4월 1일의 일기",
    "2024-04-02\n2024년 4월 2일의 일기",
    "2024-04-03\n오늘은 즐거운 날",
    "2024-04-04\n떡국 먹을걸...",
    "2024-04-05\n024년 4월 5일의 일기",
    "2024-04-06\n속상해",
    "2024-04-07\n비가 온다",
    "2024-04-08\n2024년 4월 8일의 일기",
    "2024-04-09\n2024년 4월 9일의 일기",
    "2024-04-09\n2024년 4월 9일의 일기",
    "2024-04-09\n2024년 4월 9일의 일기",
    "2024-04-09\n2024년 4월 9일의 일기",
    "2024-04-09\n2024년 4월 9일의 일기",
    "2024-04-09\n2024년 4월 9일의 일기",
    "2024-04-09\n2024년 4월 9일의 일기",
    "2024-04-09\n2024년 4월 9일의 일기",
    "2024-04-09\n2024년 4월 9일의 일기",
    "2024-04-09\n2024년 4월 9일의 일기",
    // 데이터가 더 많을 수록 페이지네이션 효과가 더 확연히 나타날 것입니다.
    // 현재는 가상의 데이터를 사용하므로 예시로 몇 개만 추가했습니다.
  ];

  // 페이지네이션 관련 변수
  static const int _entriesPerPage = 6;
  int _currentPageIndex = 0;

  // 다음 페이지를 로드하는 함수
  void _loadNextPage() {
    setState(() {
      int totalPages = (diaryEntries.length / _entriesPerPage).ceil();
      if (_currentPageIndex < totalPages - 1) {
        _currentPageIndex++;
      } else {
        // 다음 페이지가 없는 경우에 대한 처리
        // 여기서는 아무 작업도 수행하지 않습니다.
      }
    });
  }

  // 이전 페이지를 로드하는 함수
  void _loadPreviousPage() {
    setState(() {
      if (_currentPageIndex > 0) {
        _currentPageIndex--;
      } else {
        // 이전 페이지가 없는 경우에 대한 처리
        // 여기서는 아무 작업도 수행하지 않습니다.
      }
    });
  }

  // 일기 목록을 표시하는 위젯
  Widget _buildDiaryList() {
    // 전체 페이지 수 계산
    int totalPages = (diaryEntries.length / _entriesPerPage).ceil();
    List<String> currentPageEntries = diaryEntries.sublist(
        _currentPageIndex * _entriesPerPage,
        // 최소값 함수를 사용하여 실제 리스트 길이와 계산된 끝 인덱스 중 작은 값을 선택
        min((_currentPageIndex + 1) * _entriesPerPage, diaryEntries.length));

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25.0), // 양쪽 끝에 공간을 줌
            child: ListView.builder(
              // itemCount는 현재 페이지에 표시될 항목의 수
              itemCount: currentPageEntries.length,
              itemBuilder: (context, index) {
                // 전체 항목 중 현재 항목의 위치 비율
                double ratio = index / (currentPageEntries.length - 1);
                Color color;
                if (ratio <= 1 / 2) {
                  // 처음 1/3은 연한색
                  color = const Color(0xfff5b9d0);
                }
                // else if (ratio <= 2 / 3) {
                //   // 중간 1/3은 흰색
                //   // color = Colors.white;
                //   color = const Color.fromARGB(255, 229, 229, 232);
                // }
                else {
                  // 마지막 1/3은 진한색
                  color = const Color(0xff7769D4);
                }

                return GestureDetector(
                  onTap: () {
                    // 해당 날짜의 일기 페이지로 이동하는 코드를 추가합니다.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryPage(
                          selectedDay: DateTime.parse(
                              currentPageEntries[index].split('\n')[0]),
                        ),
                      ),
                    );
                  },

                  // return Column(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 일기 작성 날짜
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 5.0), // 글자를 안쪽으로 이동
                        child: Text(
                          currentPageEntries[index].split('\n')[0],
                          style: TextStyle(
                            color: color, // 여기에 계산된 색상 적용
                            // color: Color(0xff7769D4),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // 일기 제목
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 5.0), // 글자를 안쪽으로 이동
                        child: Text(
                          currentPageEntries[index].split('\n')[1],
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 230, 251),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // 점선 구분선
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CustomPaint(
                          size: const Size(double.infinity, 1),
                          painter: DottedLinePainter(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // Pagination section
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25.0), // 위쪽으로 공간을 줌
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalPages,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _currentPageIndex == index
                              ? const Color(0xff7769D4) // 선택된 페이지의 색상
                              // : const Color(0xfff5b9d0), // 선택되지 않은 페이지의 색상
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  // 날짜색
  // 날짜에 따른 MoodEntry를 가져오는 함수
  MoodEntry getMoodEntryForDate(DateTime date) {
    // 여기서는 가정하여 MoodEntry를 미리 생성해둔 것으로 가정합니다.
    // 실제로는 날짜에 맞는 MoodEntry를 데이터베이스 등에서 가져와야 합니다.
    return MoodEntry(
      date: date,
      diary_happiness: "기쁨", // 예시 감정
    );
  }

// MoodEntry 모델에서 감정에 따른 색상을 가져오는 함수
  Color getColorFromMood(String? mood) {
    return MoodEntryHelper.getColorFromMood(mood);
  }

  // 날짜색_

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '일기장',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          const Background(), // Background 위젯의 정확한 구현을 확인해주세요.
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 20.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          _showCalendarDialog(context);
                        },
                        icon: Image.asset(
                          'assets/icon/white_calendar.png',
                          width: 45,
                          height: 45,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '제목/내용',
                            fillColor: Colors.transparent,
                            filled: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10.0)
                                    .copyWith(left: 20.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 3.0),
                            ),
                            hintStyle: const TextStyle(color: Colors.white),
                            suffixIcon: const Icon(Icons.search_rounded,
                                color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 5.0),
                    child: _buildDiaryList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//

void _showCalendarDialog(BuildContext context) {
  // 색상 리스트 정의
  final List<Color> colors = [
    const Color(0xFFF5AC25), // 기쁨에 노랑
    const Color(0xFFFC819E), // 놀람에 핑크
    const Color(0xFFB3B4B4), // 불안에 회색
    const Color(0xFFBC7FCD), // 슬픔에 연보라
    const Color(0xFF86469C), // 상처에 진보라
    const Color(0xFFDF1E1E), // 분노에 빨강
  ];
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        // SizedBox의 높이를 증가시켜 색상 설명을 포함할 공간을 확보합니다.
        height: 510,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column의 크기를 내용물에 맞춥니다.
          children: [
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
                selectedDayPredicate: (day) => false,
                onDaySelected: (selectedDay, focusedDay) {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryPage(selectedDay: selectedDay),
                    ),
                  );
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    //   if (day.weekday == DateTime.sunday) {
                    //     return Container(
                    //       margin: const EdgeInsets.all(4.0),
                    //       alignment: Alignment.center,
                    //       decoration: BoxDecoration(
                    //         color: const Color(0xff845EC2).withOpacity(0.7),
                    //         shape: BoxShape.circle,
                    //       ),
                    //       child: Text(
                    //         day.day.toString(),
                    //         // style: const TextStyle(color : Colors.white),
                    //       ),
                    //     );
                    //   } else if (day.weekday == DateTime.wednesday) {
                    //       return Container(
                    //       margin: const EdgeInsets.all(4.0),
                    //       alignment: Alignment.center,
                    //       decoration: BoxDecoration(
                    //         color: const Color(0xffF9F871).withOpacity(0.8),
                    //         shape: BoxShape.circle,
                    //       ),
                    //       child: Text(
                    //         day.day.toString(),
                    //       ),
                    //       );
                    //   }

                    //   return null; // 기본 빌더 사용
                    // },
// Random 클래스를 사용하여 랜덤 인덱스 생성
                    final randomIndex = Random().nextInt(colors.length);
                    // 생성된 랜덤 인덱스를 사용하여 색상 선택
                    final color = colors[randomIndex];

                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.7), // 랜덤 색상 적용
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.day.toString(),
                        // style: TextStyle(color: color, fontSize: 24),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    // 오늘 날짜에 대한 커스텀 디자인
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent, // 배경을 투명하게 설정
                        border: Border.all(
                            color: const Color.fromARGB(
                                255, 240, 105, 161)), // 검은색 테두리
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.day.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ), // 텍스트 색상을 검은색으로 설정
                      ),
                    );
                  },
                ),
              ),
            ),
            // 색상 설명 추가(토글로..)
            const ColorLegendToggle(), // 토글 위젯 추가
          ],
        ),
      ),
    ),
  );
}

// 가상의 DiaryPage 위젯
class DiaryPage extends StatelessWidget {
  final DateTime selectedDay;

  const DiaryPage({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${selectedDay.toIso8601String()} 일기"),
      ),
      body: const Center(
        child: Text("여기에 일기 내용이 표시됩니다."),
      ),
    );
  }
}
