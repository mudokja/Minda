// import 'package:flutter/material.dart';
// import 'package:diary_fe/src/models/DiaryEntry.dart';

// class DiaryDetailPage extends StatelessWidget {
//   final DiaryEntry entry;

//   const DiaryDetailPage({super.key, required this.entry});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(entry.diaryTitle ?? "No Title"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () {
//               // 편집 페이지로 이동하는 로직
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: () {
//               // 삭제 확인 다이얼로그 표시
//               _confirmDeletion(context, entry);
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               "Date: ${entry.diarySetDate}",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "Content: ${entry.diaryContent}",
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _confirmDeletion(BuildContext context, DiaryEntry entry) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Confirm Deletion"),
//           content: const Text("Are you sure you want to delete this entry?"),
//           actions: <Widget>[
//             TextButton(
//               child: const Text("Cancel"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text("Delete"),
//               onPressed: () {
//                 // 일기 삭제 로직 실행
//                 Navigator.of(context).pop(); // 다이얼로그 닫기
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary_fe/src/services/diary_provider.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';

class DiaryListPage extends StatefulWidget {
  final DateTime selectedDay;

  // 기본값을 제거하고, nullable로 선언 후 생성자 본문에서 할당
  DiaryListPage({super.key, DateTime? selectedDay})
    : selectedDay = selectedDay ?? DateTime.now();

  @override
  _DiaryListPageState createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  @override
  @override
  void initState() {
    super.initState();
    // 데이터를 초기에 로드합니다.
    // 여기에서 선택된 날짜를 사용하여 특정 데이터를 필터링할 수 있습니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedDay.toIso8601String()}의 일기 목록'),
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, provider, child) {
          // 로딩 상태 처리
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // 데이터 없음 처리
          if (provider.entries.isEmpty) {
            return const Center(child: Text("No diary entries found"));
          }
          // 데이터가 있는 경우
          return ListView.builder(
            itemCount: provider.entries.length,
            itemBuilder: (context, index) {
              DiaryEntry entry = provider.entries[index];
              return ListTile(
                title: Text(entry.diaryTitle ?? 'No Title'),
                subtitle: Text("Set on ${entry.diarySetDate}"),
                onTap: () {
                  // 여기서 상세 페이지로 네비게이션 할 수 있습니다.
                },
              );
            },
          );
        },
      ),
    );
  }
}

