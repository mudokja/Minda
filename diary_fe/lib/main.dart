import 'package:diary_fe/src/screens/intro_page.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:diary_fe/src/screens/diary_list_page.dart';
import 'package:diary_fe/src/models/MoodEntry.dart'; // MoodEntry를 import 해야합니다.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Background(), // 기본 배경
            // IntroPage(),
            DiaryListPage(),
          ],
        ),
      ),
    );
  }
}
