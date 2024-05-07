import 'package:diary_fe/firebase_options.dart';
import 'package:diary_fe/src/screens/intro_page.dart';
import 'package:diary_fe/src/screens/pages.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:diary_fe/src/screens/diary_list_page.dart';
import 'package:diary_fe/src/models/MoodEntry.dart'; // MoodEntry를 import 해야합니다.
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:diary_fe/src/services/services_initializer.dart'; // setup.dart 파일 import
// main.dart 파일
import 'package:flutter/material.dart';
import 'package:diary_fe/src/services/services_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '1725e254be43deb4ed9e5624c1db2f57',
    javaScriptAppKey: 'ca31cb2221c9049fe00179bcb39df4b0',
  );
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
