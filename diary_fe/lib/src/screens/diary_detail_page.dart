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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';
import 'package:diary_fe/src/services/diary_provider.dart';
import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/widgets/background.dart'; // Background 위젯 import

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
      // appBar: AppBar(
      //   title: const Text('일기 상세'),
      // ),
      body: Stack(
        children: [
          const Background(), // 배경 위젯
          Center( // Center 위젯을 사용하여 중앙에 배치
          // Padding(
          //   padding: const EdgeInsets.all(16),
             child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9, // 최대 높이 설정
              ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, // 화면의 90% 크기
              decoration: BoxDecoration(
                
                color: Colors.white, // 컨테이너의 배경색
                borderRadius: BorderRadius.circular(35), // 모서리 둥글게
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // 그림자 위치 조정
                  ),
                ],
              ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 내부 여백 추가
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // 가로로 꽉 차게
                children: [
                  Padding(
                    // padding: const EdgeInsets.only(left: 20, right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10), // 좌우 여백
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded( // 텍스트가 버튼을 침범하지 않도록 Expanded 사용
                        child: Text(
                          '작성된 일기',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: themeColors.color2,
                          ),
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
          ),
          ),
          ),
        ],
      ),
    );
  }
}
