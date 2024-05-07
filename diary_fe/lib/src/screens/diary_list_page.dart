import 'package:diary_fe/src/screens/diary_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary_fe/src/services/diary_provider.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';
import 'package:diary_fe/src/services/diary_api_service.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:diary_fe/src/widgets/calendar_dialog.dart';
import 'package:diary_fe/src/utils/dotted_line_painter.dart';
import 'package:diary_fe/src/screens/write_page.dart';

// DiaryListPage 스테이트풀 위젯
class DiaryListPage extends StatefulWidget {
  // const DiaryListPage({super.key});

  final DateTime selectedDay; // 이 클래스에 `selectedDay`를 정의합니다.

  // 생성자에서 `selectedDay`를 받아서 저장합니다.
  const DiaryListPage({super.key, required this.selectedDay});

  @override
  _DiaryListPageState createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  List<DiaryEntry> diaryEntries = [];
  bool isLoading = true;

  static const int _entriesPerPage = 6;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchEntries();
  }

  // 데이터를 비동기적으로 불러오는 함수
  void fetchEntries() async {
    var diaryService = DiaryApiService(); // DiaryApiService 인스턴스 생성
    try {
      diaryEntries =
          await diaryService.fetchDiaryEntries(); // 일기 목록을 비동기적으로 불러옵니다.
      if (diaryEntries.isEmpty) {
        print('No entries returned from the server.');
      }
    } catch (e) {
      print('Error fetching diary entries: $e');
      // 에러 발생 시 사용자에게 알림
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Failed to fetch diary entries. Please try again later.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadNextPage() {
    setState(() {
      int totalPages = (diaryEntries.length / _entriesPerPage).ceil();
      if (_currentPageIndex < totalPages - 1) {
        _currentPageIndex++;
      }
    });
  }

  void _loadPreviousPage() {
    setState(() {
      if (_currentPageIndex > 0) {
        _currentPageIndex--;
      }
    });
  }

  void fetchDiaryEntries() async {
    setState(() => isLoading = true);
    try {
      // 여기에 데이터 가져오는 로직 구현
      // 예: diaryEntries = await DiaryApiService.getDiaryEntries();
      setState(() => isLoading = false);
    } catch (e) {
      print('Error fetching diary entries: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (diaryEntries.length / _entriesPerPage).ceil();
    List<DiaryEntry> currentPageEntries = diaryEntries.sublist(
      _currentPageIndex * _entriesPerPage,
      (_currentPageIndex + 1) * _entriesPerPage > diaryEntries.length
          ? diaryEntries.length
          : (_currentPageIndex + 1) * _entriesPerPage,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('일기장',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          const Background(),
          SafeArea(
            child: Column(
              children: <Widget>[
                // 검색바 및 캘린더 아이콘
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 20.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () =>
                            CalendarDialog.showCalendarDialog(context),
                        icon: Image.asset('assets/icon/white_calendar.png',
                            width: 45, height: 45),
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
                // 일기 목록 표시
                const SizedBox(height: 10), // 검색바와 일기 목록 사이의 간격 추가
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 25.0), // 양쪽 끝에 공간을 줌
                          child: ListView.builder(
                            itemCount: currentPageEntries.length,
                            itemBuilder: (context, index) {
                              // 전체 항목 중 현재 항목의 위치 비율
                              double ratio =
                                  index / (currentPageEntries.length - 1);
                              Color color;
                              if (ratio <= 0.5) {
                                // 처음 절반은 연한색
                                color = const Color(0xfff5b9d0);
                              } else {
                                // 마지막 절반은 진한색
                                color = const Color(0xff7769D4);
                              }

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DiaryDetailPage(
                                        selectedDay: DateTime.parse(
                                            currentPageEntries[index]
                                                .diarySetDate), // 일기 날짜를 DateTime 객체로 변환
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        currentPageEntries[index]
                                            .diarySetDate, // 날짜 직접 사용
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Text(
                                        currentPageEntries[index].diaryTitle ??
                                            'No Title', // 제목 직접 사용
                                        style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 230, 251),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: CustomPaint(
                                        size: const Size(double.infinity, 1),
                                        painter: DottedLinePainter(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
                // 페이지네이션 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, top: 5.0), // 왼쪽 마진 추가
                      child: IconButton(
                        onPressed: _loadPreviousPage,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: const Color(0xff7769D4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0), // 오른쪽 마진 추가
                      child: IconButton(
                        onPressed: _loadNextPage,
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        color: const Color(0xff7769D4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}               
//                 // 페이지네이션 바
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     totalPages,
//                     (index) => Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       child: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _currentPageIndex = index;
//                           });
//                         },
//                         child: Text(
//                           '${index + 1}',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: _currentPageIndex == index
//                                 ? const Color(0xff7769D4)
//                                 : Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
