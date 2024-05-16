import 'package:flutter/material.dart';
import 'package:diary_fe/constants.dart'; // ThemeColors 클래스 import
import 'package:diary_fe/src/screens/intro_page.dart';
import 'package:diary_fe/src/screens/pages.dart';
import 'package:provider/provider.dart';
import 'package:diary_fe/src/services/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 4)); // 4초 대기

    // 로그인 상태에 따라 다른 페이지로 이동
    bool isLoggedIn = context.read<UserProvider>().isLoggedIn;
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Pages()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const IntroPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // 배경색을 흰색으로 설정
        child: Center(
          child: Image.asset(
            'assets/gifs/logo.gif',
            width: 300, // 로고의 너비를 더 크게 설정
            height: 300, // 로고의 높이를 더 크게 설정
          ),
        ),
      ),
    );
  }
}
