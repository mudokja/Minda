import 'package:flutter/material.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';

class DiaryDetailPage extends StatelessWidget {
  final DiaryEntry entry;

  const DiaryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.diaryTitle ?? "No Title"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 편집 페이지로 이동하는 로직
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // 삭제 확인 다이얼로그 표시
              _confirmDeletion(context, entry);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Date: ${entry.diarySetDate}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Content: ${entry.diaryContent}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletion(BuildContext context, DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this entry?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                // 일기 삭제 로직 실행
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
}
