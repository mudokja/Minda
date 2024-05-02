import 'package:diary_fe/src/screens/intro_page.dart';
import 'package:diary_fe/src/screens/pages.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:diary_fe/src/screens/diary_list_page.dart';
import 'package:diary_fe/src/models/MoodEntry.dart'; // MoodEntry를 import 해야합니다.
import 'package:provider/provider.dart';
import 'package:diary_fe/src/services/services_initializer.dart';  // setup.dart 파일 import

// void main() {
//   runApp(const MyApp());
// }

// void main() {
//   runApp(
//     initializeDiaryProvider(), // setup.dart에서 초기화
//     child: const MyApp(),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider<UserProvider>(
//           create: (context) => UserProvider(),
//         ),
//       ],
//       child: MaterialApp(
//         localizationsDelegates: const [
//           GlobalMaterialLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//           GlobalCupertinoLocalizations.delegate,
//         ],
//         supportedLocales: const [
//           Locale('ko', 'KR'),
//         ],
//         home: Consumer<UserProvider>(
//           builder: (context, userProvider, child) {
//             // 로그인 상태에 따라 다른 페이지 렌더링
//             return Scaffold(
//               body: userProvider.isLoggedIn ? const Pages() : const IntroPage(),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
// main.dart 파일
import 'package:flutter/material.dart';
import 'package:diary_fe/src/services/services_initializer.dart'; 

void main() {
  runApp(initializeDiaryProvider());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // 로그인 상태에 따라 다른 페이지 렌더링
          return Scaffold(
            body: userProvider.isLoggedIn ? const Pages() : const IntroPage(),
          );
        },
      ),
    );
  }
}
