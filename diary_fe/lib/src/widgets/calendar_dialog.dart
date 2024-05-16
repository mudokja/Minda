import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:diary_fe/src/widgets/color_legend_toggle.dart';
import 'dart:math';
// import 'package:diary_fe/src/screens/diary_list_page.dart';
import 'package:diary_fe/src/screens/diary_detail_page.dart';
import 'package:diary_fe/src/services/diary_api_service.dart';
import 'package:diary_fe/src/screens/write_page.dart';
import 'package:diary_fe/src/services/diary_provider.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';
import 'package:diary_fe/src/screens/diary_detail_page.dart';
import 'package:dio/dio.dart';
import 'package:diary_fe/src/services/api_services.dart';

class CalendarDialog {
  static Future<List<Map<String, dynamic>>> fetchDiaryEntriesByPeriod(
      DateTime startDate, DateTime endDate) async {
    final apiService = ApiService();
    const url = '/api/diary/list/period';
    final data = {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };

    try {
      Response response = await apiService.post(url, data: data);
      print('API 호출 성공: ${response.statusCode}');
      print('응답 데이터: ${response.data}');
      if (response.statusCode == 200) {
        List<dynamic> responseData = response.data;
        return List<Map<String, dynamic>>.from(responseData);
      } else {
        throw Exception('Failed to load diary entries');
      }
    } catch (e) {
      print('API 호출 실패: $e');
      throw Exception('Failed to load diary entries: $e');
    }
  }

  static void showCalendarDialog(BuildContext context) {
//     final List<Color> colors = [
//       const Color(0xFFF5AC25), // 기쁨에 노랑
//       const Color(0xFFFC819E), // 놀람에 핑크
//       // const Color(0xFFB3B4B4), // 불안에 회색
//       const Color(0xFFBC7FCD), // 슬픔에 연보라
//       const Color(0xFF86469C), // 불안에 진보라
//       const Color(0xFFDF1E1E), // 분노에 빨강
//     ];

//     // 새로운 함수 추가
//   static Future<List<DiaryEntry>> fetchDiaryEntriesByPeriod(DateTime startDate, DateTime endDate) async {
//     final response = await http.post(
//       Uri.parse('https://k10b205.p.ssafy.io/api/diary/list/period'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, String>{
//         'startDate': startDate.toIso8601String(),
//         'endDate': endDate.toIso8601String(),
//       }),
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> data = jsonDecode(response.body);
//       return data.map((item) => DiaryEntry.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to load diary entries');
//     }
//   }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         content: SizedBox(
//           width: double.maxFinite,
//           // SizedBox의 높이를 증가시켜 색상 설명을 포함할 공간을 확보합니다.
//           height: 510,
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // Column의 크기를 내용물에 맞춥니다.
//             children: [
//               Expanded(
//                 child: TableCalendar(
//                   firstDay: DateTime.utc(2010, 10, 16),
//                   lastDay: DateTime.utc(2030, 3, 14),
//                   focusedDay: DateTime.now(),
//                   selectedDayPredicate: (day) => false,
//                   // onDaySelected: (selectedDay, focusedDay) {
//                   //   Navigator.pop(context); // 다이얼로그 닫기
//                   //   Navigator.push(
//                   //     context,
//                   //     MaterialPageRoute(
//                   //       builder: (context) => Write(selectedDay: DateTime.now()),
//                   //     ),
//                   //   );
//                   // },

// // onDaySelected: (selectedDay, focusedDay) {
// //   Navigator.pop(context); // 다이얼로그 닫기
// //   DiaryApiService diaryService = DiaryApiService();

// //   diaryService.fetchDiaryEntryByDate(selectedDay).then((diaryEntry) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => DiaryDetailPage(
// //           selectedDay: selectedDay,
// //           diaryTitle: diaryEntry.diaryTitle,
// //           diaryContent: diaryEntry.diaryContent,
// //         ),
// //       ),
// //     );
// //   }).catchError((error) {
// //     print("Error fetching diary for selected day: $error");
// //     // 오류 발생 시 사용자에게 알림, 예를 들어 Snackbar 사용
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('Failed to load diary entry. Please try again later.'))
// //     );
//                   // });
//                   onDaySelected: (selectedDay, focusedDay) {
//                     Navigator.pop(context); // 다이얼로그 닫기
//                     DiaryApiService diaryService = DiaryApiService();

//                     diaryService
//                         .fetchDiaryEntriesByDate(selectedDay)
//                         .then((diaryEntries) {
//                       if (diaryEntries.isNotEmpty) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DiaryDetailPage(
//                               selectedDay: selectedDay,
//                               diaryTitle:
//                                   diaryEntries.first.diaryTitle, // 첫 번째 일기의 제목
//                               diaryContent: diaryEntries
//                                   .first.diaryContent, // 첫 번째 일기의 내용
//                                   diaryIndex: diaryEntries.first.diaryIndex,
//                             ),
//                           ),
//                         );
//                       } else {
//                         // 일기가 없는 경우 사용자에게 알림
//                         ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text(
//                                     'No diary entries found for this date.')));
//                       }
//                     }).catchError((error) {
//                       print("Error fetching diary for selected day: $error");
//                       // 오류 발생 시 사용자에게 알림
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                           content: Text(
//                               'Failed to load diary entry. Please try again later.')));
//                     });
//                   },

//                   calendarBuilders: CalendarBuilders(
//                     defaultBuilder: (context, day, focusedDay) {
//                       final randomIndex = Random().nextInt(colors.length);
//                       // 생성된 랜덤 인덱스를 사용하여 색상 선택
//                       final color = colors[randomIndex];

//                       return Container(
//                         margin: const EdgeInsets.all(4.0),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: color.withOpacity(0.7), // 랜덤 색상 적용
//                           shape: BoxShape.circle,
//                         ),
//                         child: Text(
//                           day.day.toString(),
//                           // style: TextStyle(color: color, fontSize: 24),
//                         ),
//                       );
//                     },
//                     todayBuilder: (context, day, focusedDay) {
//                       // 오늘 날짜에 대한 커스텀 디자인
//                       return Container(
//                         margin: const EdgeInsets.all(4.0),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: Colors.transparent, // 배경을 투명하게 설정
//                           border: Border.all(
//                               color: const Color.fromARGB(
//                                   255, 240, 105, 161)), // 검은색 테두리
//                           shape: BoxShape.circle,
//                         ),
//                         child: Text(
//                           day.day.toString(),
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ), // 텍스트 색상을 검은색으로 설정
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               // 색상 설명 추가(토글로..)
//               const ColorLegendToggle(), // 토글 위젯 추가
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

////////////////////////////
    DateTime firstDay = DateTime.utc(2010, 10, 16);
    DateTime lastDay = DateTime.utc(2030, 3, 14);
    DateTime focusedDay = DateTime.now();

    fetchDiaryEntriesByPeriod(firstDay, lastDay).then((diaryEntries) {
      print('일기 데이터 가져오기 성공: $diaryEntries');
      Map<DateTime, Color> dayColors = {};

      for (var entry in diaryEntries) {
        DateTime date = DateTime.parse(entry['diarySetDate'])
            .toLocal(); // 시간 정보를 제거하여 날짜만 비교
        double maxEmotionValue = [
          entry['diaryHappiness'],
          entry['diarySadness'],
          entry['diaryFear'],
          entry['diaryAnger'],
          entry['diarySurprise']
        ].reduce((a, b) => a > b ? a : b);

        Color color;
        if (maxEmotionValue == entry['diaryHappiness']) {
          color = const Color(0xFFF5AC25); // 기쁨
        } else if (maxEmotionValue == entry['diarySurprise']) {
          color = const Color(0xFFFC819E); // 놀람
        } else if (maxEmotionValue == entry['diarySadness']) {
          color = const Color(0xFFBC7FCD); // 슬픔
        } else if (maxEmotionValue == entry['diaryAnger']) {
          color = const Color(0xFFDF1E1E); // 분노
        } else {
          color = const Color(0xFF86469C); // 불안
        }

        // 날짜만 포함한 DateTime 객체로 키 설정
        dayColors[DateTime(date.year, date.month, date.day)] = color;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            height: 510,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TableCalendar(
                    firstDay: firstDay,
                    lastDay: lastDay,
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) => false,
                    onDaySelected: (selectedDay, focusedDay) {
                      Navigator.pop(context);
                      fetchDiaryEntriesByPeriod(selectedDay, selectedDay)
                          .then((diaryEntries) {
                        if (diaryEntries.isNotEmpty) {
                          var entry = diaryEntries.first;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiaryDetailPage(
                                selectedDay: selectedDay,
                                diaryTitle: entry['diaryTitle'],
                                diaryContent: entry['diaryContent'],
                                diaryIndex: entry['diaryIndex'],
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'No diary entries found for this date.')),
                          );
                        }
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Failed to load diary entry. Please try again later.')),
                        );
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        // 날짜 비교를 위해 날짜만 포함한 DateTime 객체로 변환
                        DateTime dateOnly =
                            DateTime(day.year, day.month, day.day);
                        Color? color = dayColors[dateOnly];

                        if (color != null) {
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              day.day.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString(),
                              style: const TextStyle(
                                color: Color.fromARGB(149, 86, 5, 126),
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color:
                                    const Color.fromARGB(255, 240, 105, 161)),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            day.day.toString(),
                            style: const TextStyle(
                              color: Color.fromARGB(149, 86, 5, 126),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const ColorLegendToggle(),
              ],
            ),
          ),
        ),
      );
    }).catchError((error) {
      print('Error fetching diary entries: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Failed to load diary entries. Please try again later.')),
      );
    });
  }
}
