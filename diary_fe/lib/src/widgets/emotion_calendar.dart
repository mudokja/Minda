import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';
import 'package:diary_fe/src/services/api_services.dart';  // ApiService가 정의된 파일 이름 확인 필요
import 'package:diary_fe/src/widgets/color_legend_toggle.dart';
import 'package:diary_fe/src/screens/diary_detail_page.dart';
import 'package:diary_fe/src/services/diary_api_service.dart';  // ApiService 사용하는 경우 여기서도 확인 필요
import 'package:diary_fe/src/screens/write_page.dart';
import 'package:diary_fe/src/services/diary_provider.dart';  // 실제 사용되고 있는지 확인 필요

// class EmotionCalendar extends StatefulWidget {
//   const EmotionCalendar({super.key});

//   @override
//   _EmotionCalendarState createState() => _EmotionCalendarState();
// }

// class _EmotionCalendarState extends State<EmotionCalendar> {
//   DateTime _focusedDay = DateTime.now();
//   Map<DateTime, Color> _emotionColors = {};
//   final ApiService _apiService = ApiService();

//   @override
//   void initState() {
//     super.initState();
//     fetchDiaryEntriesForMonth(_focusedDay);
//   }

//   // 달력에 표시할 월별 일기 데이터를 가져옵니다.
//   Future<void> fetchDiaryEntriesForMonth(DateTime date) async {
//     DateTime startOfMonth = DateTime(date.year, date.month, 1);
//     DateTime endOfMonth = DateTime(date.year, date.month + 1, 0);

//     try {
//       List<DiaryEntry> diaries = await fetchDiaries(startOfMonth, endOfMonth);
//       Map<DateTime, Color> newEmotionColors = {};
//       for (var diary in diaries) {
//         DateTime diaryDate = DateTime.parse(diary.diarySetDate);
//         var maxEmotion = _getMaxEmotion(diary);
//         newEmotionColors[diaryDate] = _emotionToColor(maxEmotion);
//       }
//       setState(() {
//         _emotionColors = newEmotionColors;
//       });
//     } catch (e) {
//       print('Error fetching diaries: $e');
//     }
//   }
  
//    Future<List<DiaryEntry>> fetchDiaries(DateTime startDate, DateTime endDate) async {
//     final response = await _apiService.post('/api/diary/list/period', data: {
//       'startDate': DateFormat('yyyy-MM-dd').format(startDate),
//       'endDate': DateFormat('yyyy-MM-dd').format(endDate),
//     });

//     if (response.statusCode == 200) {
//       return (response.data as List).map((item) => DiaryEntry.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to load diaries with status code: ${response.statusCode}');
//     }
//   }


//   String _getMaxEmotion(DiaryEntry diary) {
//     Map<String, double> emotions = {
//       'happiness': diary.diaryHappiness,
//       'sadness': diary.diarySadness,
//       'fear': diary.diaryFear,
//       'anger': diary.diaryAnger,
//       'surprise': diary.diarySurprise
//     };
//     var sortedEmotions = emotions.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));
//     return sortedEmotions.first.key;
//   }

//   Color _emotionToColor(String emotion) {
//     switch (emotion) {
//       case 'happiness':
//         return const Color(0xFFF5AC25); // 노랑
//       case 'surprise':
//         return const Color(0xFFFC819E); // 핑크
//       case 'sadness':
//         return const Color(0xFFBC7FCD); // 연보라
//       case 'anger':
//         return const Color(0xFFDF1E1E); // 빨강
//       case 'fear':
//         return const Color(0xFF86469C); // 진보라
//       default:
//         return Colors.grey; // 기본 색상
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: TableCalendar(
//         firstDay: DateTime.utc(2010, 10, 16),
//         lastDay: DateTime.utc(2030, 3, 14),
//         focusedDay: _focusedDay,
//         calendarBuilders: CalendarBuilders(
//           defaultBuilder: (context, day, focusedDay) {
//             return Container(
//               margin: const EdgeInsets.all(4.0),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: _emotionColors[day] ?? Colors.transparent,
//                 shape: BoxShape.circle,
//               ),
//               child: Text(
//                 day.day.toString(),
//                 style: const TextStyle(color: Colors.white),
//               ),
//             );
//           },
//         ),
//         onPageChanged: (focusedDay) {
//           _focusedDay = focusedDay;
//           fetchDiaryEntriesForMonth(focusedDay);
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:diary_fe/src/services/diary_api_service.dart';
import 'package:diary_fe/src/screens/diary_detail_page.dart';

class EmotionCalendar {
  static void showEmotionCalendar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: double.maxFinite,
          height: 510, // 필요에 따라 조정
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: DateTime.now(),
                  onDaySelected: (selectedDay, focusedDay) {
                    Navigator.pop(context); // 다이얼로그 닫기
                    // 추가적인 액션 구현
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        // alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue[200], // 색상은 상황에 맞게 조정
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          day.day.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
