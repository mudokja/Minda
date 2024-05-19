// // main.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:dio/dio.dart';
// import 'package:diary_fe/src/services/diary_api_service.dart';
// import 'package:diary_fe/src/services/diary_provider.dart';
// import 'package:diary_fe/main.dart'; // MyApp 정의를 포함한 파일 경로

// void main() {
//   final dio = Dio();  // Dio 인스턴스 생성
//   final diaryApiService = DiaryApiService(dio);  // API 서비스 인스턴스 생성

//   runApp(
//     Provider<DiaryProvider>(
//       create: (_) => DiaryProvider(diaryApiService),
//       child: const MyApp(),
//     ),
//   );
// }

// setup.dart 파일
import 'package:diary_fe/src/widgets/stt_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:diary_fe/src/services/diary_api_service.dart';
import 'package:diary_fe/src/services/diary_provider.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:diary_fe/main.dart'; // MyApp 정의를 포함한 파일 경로
import 'package:diary_fe/src/models/DiaryEntry.dart';

Widget initializeDiaryProvider() {
  // Dio 인스턴스 생성 과정을 제거합니다.
  final diaryApiService = DiaryApiService();  // API 서비스 인스턴스 생성, 내부에서 Dio 인스턴스를 생성하므로 인자 필요 없음

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<DiaryProvider>(
        create: (_) => DiaryProvider(diaryApiService),
      ),
      ChangeNotifierProvider<UserProvider>(
        create: (_) => UserProvider(),
      ),
      ChangeNotifierProvider<STTProvider>(
        create: (_) => STTProvider(),
      ),
    ],
    child: const MyApp(),
  );
}

