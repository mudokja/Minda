import 'package:diary_fe/src/screens/intro_page.dart';
import 'package:diary_fe/src/screens/pages.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:diary_fe/src/screens/diary_list_page.dart';
import 'package:diary_fe/src/models/MoodEntry.dart'; // MoodEntry를 import 해야합니다.
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '1725e254be43deb4ed9e5624c1db2f57',
    javaScriptAppKey: 'ca31cb2221c9049fe00179bcb39df4b0',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
