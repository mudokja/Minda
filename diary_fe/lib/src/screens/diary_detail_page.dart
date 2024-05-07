// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:diary_fe/src/services/diary_provider.dart';
// import 'package:diary_fe/src/models/DiaryEntry.dart';

// class DiaryListPage extends StatefulWidget {
//   final DateTime selectedDay;

//   // 기본값을 제거하고, nullable로 선언 후 생성자 본문에서 할당
//   DiaryListPage({super.key, DateTime? selectedDay})
//     : selectedDay = selectedDay ?? DateTime.now();

//   @override
//   _DiaryListPageState createState() => _DiaryListPageState();
// }

// class _DiaryListPageState extends State<DiaryListPage> {
//   @override
//   @override
//   void initState() {
//     super.initState();
//     // 데이터를 초기에 로드합니다.
//     // 여기에서 선택된 날짜를 사용하여 특정 데이터를 필터링할 수 있습니다.
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.selectedDay.toIso8601String()}의 일기 목록'),
//       ),
//       body: Consumer<DiaryProvider>(
//         builder: (context, provider, child) {
//           // 로딩 상태 처리
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           // 데이터 없음 처리
//           if (provider.entries.isEmpty) {
//             return const Center(child: Text("No diary entries found"));
//           }
//           // 데이터가 있는 경우
//           return ListView.builder(
//             itemCount: provider.entries.length,
//             itemBuilder: (context, index) {
//               DiaryEntry entry = provider.entries[index];
//               return ListTile(
//                 title: Text(entry.diaryTitle ?? 'No Title'),
//                 subtitle: Text("Set on ${entry.diarySetDate}"),
//                 onTap: () {
//                   // 여기서 상세 페이지로 네비게이션 할 수 있습니다.
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:diary_fe/src/services/diary_provider.dart';
// import 'package:diary_fe/src/models/DiaryEntry.dart';

// class DiaryDetailPage extends StatefulWidget {
//   final DateTime selectedDay;

//   DiaryDetailPage({super.key, DateTime? selectedDay})
//     : selectedDay = selectedDay ?? DateTime.now();

//   @override
//   _DiaryDetailPageState createState() => _DiaryDetailPageState();
// }

// class _DiaryDetailPageState extends State<DiaryDetailPage> {
//   @override
//   void initState() {
//     super.initState();
//     // 데이터 로드 및 필터링 로직을 초기화
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.selectedDay.toIso8601String()}의 일기 상세'),
//       ),
//       body: Consumer<DiaryProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (provider.entries.isEmpty) {
//             return const Center(child: Text("No diary entries found"));
//           }
//           return ListView.builder(
//             itemCount: provider.entries.length,
//             itemBuilder: (context, index) {
//               DiaryEntry entry = provider.entries[index];
//               return ListTile(
//                 title: Text(entry.diaryTitle ?? 'No Title'),
//                 subtitle: Text("Set on ${entry.diarySetDate}"),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => DiaryDetailInfoPage(
//                         selectedDay: DateTime.parse(entry.diarySetDate), // 문자열을 DateTime 객체로 변환
//                         diaryTitle: entry.diaryTitle,
//                         diaryContent: entry.diaryContent,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class DiaryDetailInfoPage extends StatefulWidget {
//   final DateTime selectedDay;
//   final String diaryTitle;
//   final String diaryContent;

//   const DiaryDetailInfoPage({
//     super.key,
//     required this.selectedDay,
//     required this.diaryTitle,
//     required this.diaryContent,
//   });

//   @override
//   State<DiaryDetailInfoPage> createState() => _DiaryDetailInfoPageState();
// }

// class _DiaryDetailInfoPageState extends State<DiaryDetailInfoPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('일기 상세'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.diaryTitle,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               widget.diaryContent,
//               style: const TextStyle(fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';
import 'package:diary_fe/src/services/diary_provider.dart';
import 'package:diary_fe/constants.dart';

class DiaryDetailPage extends StatefulWidget {

  final DateTime selectedDay;
  final String diaryTitle;
  final String diaryContent;

  const DiaryDetailPage({
    super.key,
    required this.selectedDay,
    required this.diaryTitle,
    required this.diaryContent,
  });

  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  bool showConfirmationView = false; // 상태를 관리하는 변수

  void _toggleConfirmationView() {
    setState(() {
      showConfirmationView = !showConfirmationView;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors(); // 테마 색상 인스턴스

    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 상세'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '작성된 일기',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: themeColors.color2,
                    ),
                  ),
                  SizedBox(
                    width: 80, // 너비를 늘림
                    height: 40, // 높이를 늘림
                    child: TextButton(
                      onPressed: _toggleConfirmationView,
                      child: Text(
                        '수정하기',
                        style: TextStyle(
                            color: themeColors.color1,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.diaryContent,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
