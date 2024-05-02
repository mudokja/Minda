import 'package:diary_fe/src/widgets/background.dart'; // 이 부분은 실제 경로에 맞게 조정해주세요.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary_fe/src/services/diary_provider.dart';
import 'package:diary_fe/src/services/diary_api_service.dart';
import 'package:flutter/widgets.dart';
import 'package:diary_fe/src/utils/dotted_line_painter.dart';
import 'package:diary_fe/src/widgets/color_legend_toggle.dart';
import 'package:diary_fe/src/widgets/calendar_dialog.dart';
import 'package:dio/dio.dart';


import 'dart:math';
// MoodEntry 모델과 getColorFromMood 함수를 import 합니다.
import 'package:diary_fe/src/models/MoodEntry.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';
import 'package:diary_fe/src/models/MoodEntry.dart' as MoodEntryHelper;
import 'dart:math';

import 'package:table_calendar/table_calendar.dart';


class DiaryList extends StatelessWidget {
  const DiaryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('일기장', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          const Background(),
          Consumer<DiaryProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) return const Center(child: CircularProgressIndicator());
              if (provider.entries.isEmpty) return const Center(child: Text("No diary entries found"));
              return ListView.builder(
                itemCount: provider.entries.length,
                itemBuilder: (context, index) {
                  final entry = provider.entries[index];
                  return ListTile(
                    title: Text(entry.diaryTitle ?? 'No Title'),
                    subtitle: Text("Set on ${entry.diarySetDate} - Happiness: ${entry.diaryHappiness}, Sadness: ${entry.diarySadness}"),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
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
// }


class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  _DiaryListPageState createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  List<DiaryEntry> diaryEntries = [];

  @override
  void initState() {
    super.initState();
    fetchEntries();
  }

void fetchEntries() async {
  var diaryService = DiaryApiService();  // DiaryApiService 인스턴스 생성
  try {
    diaryEntries = await diaryService.fetchDiaryEntries();  // 일기 목록을 비동기적으로 불러옵니다.
    setState(() {});  // 상태 업데이트
  } catch (e) {
    print('Error fetching diary entries: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary List'),
      ),
      body: diaryEntries.isEmpty
          ? const Center(child: Text("No diary entries found"))
          : ListView.builder(
              itemCount: diaryEntries.length,
              itemBuilder: (context, index) {
                DiaryEntry entry = diaryEntries[index];
                return ListTile(
                  title: Text(entry.diaryTitle ?? 'No Title'),
                  subtitle: Text(entry.diarySetDate ?? 'No Date'),
                );
              },
            ),
    );
  }
}






// DiaryListPage
// class DiaryListPage extends StatefulWidget {
//   const DiaryListPage({super.key});

//   @override
//   _DiaryListPageState createState() => _DiaryListPageState();
// }

// class _DiaryListPageState extends State<DiaryListPage> {


//   // 날짜색
//   // 날짜에 따른 MoodEntry를 가져오는 함수
//   MoodEntry getMoodEntryForDate(DateTime date) {
//     // 여기서는 가정하여 MoodEntry를 미리 생성해둔 것으로 가정합니다.
//     // 실제로는 날짜에 맞는 MoodEntry를 데이터베이스 등에서 가져와야 합니다.
//     return MoodEntry(
//       date: date,
//       diary_happiness: "기쁨", // 예시 감정
//     );
//   }

// // MoodEntry 모델에서 감정에 따른 색상을 가져오는 함수
//   Color getColorFromMood(String? mood) {
//     return MoodEntryHelper.getColorFromMood(mood);
//   }

//   // 날짜색_

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text(
//           '일기장',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0.0,
//       ),
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: <Widget>[
//           const Background(), // Background 위젯의 정확한 구현을 확인해주세요.
//           SafeArea(
//             child: Column(
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 0.0, horizontal: 20.0),
//                   child: Row(
//                     children: <Widget>[
//                       IconButton(
//                         onPressed: () {
//                           CalendarDialog.showCalendarDialog(context);
//                         },
//                         icon: Image.asset(
//                           'assets/icon/white_calendar.png',
//                           width: 45,
//                           height: 45,
//                         ),
//                       ),
//                       const SizedBox(width: 13),
//                       Expanded(
//                         child: TextField(
//                           style: const TextStyle(color: Colors.white),
//                           decoration: InputDecoration(
//                             hintText: '제목/내용',
//                             fillColor: Colors.transparent,
//                             filled: true,
//                             contentPadding:
//                                 const EdgeInsets.symmetric(vertical: 10.0)
//                                     .copyWith(left: 20.0),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: BorderSide.none,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: const BorderSide(
//                                   color: Colors.white, width: 2.0),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: const BorderSide(
//                                   color: Colors.white, width: 3.0),
//                             ),
//                             hintStyle: const TextStyle(color: Colors.white),
//                             suffixIcon: const Icon(Icons.search_rounded,
//                                 color: Colors.white, size: 30),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 20.0, horizontal: 5.0),
//                     child: _buildDiaryList(),
//                     // child: _buildDiaryListWithButtons(), // 변경된 함수 사용
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
