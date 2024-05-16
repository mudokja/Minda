import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/screens/intro_page.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/services/delete_storage.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:diary_fe/src/widgets/change_nickname.dart';
import 'package:diary_fe/src/widgets/change_password.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ApiService apiService = ApiService();
  final storage = const FlutterSecureStorage();
  String platform = '';

  void logout() async {
    if (kIsWeb) {
      setState(() {
        platform = "WEB";
      });
    } else {
      setState(() {
        platform = "ANDROID";
      });
    }

    // Response response = await apiService.delete(
    //   '/api/notification',
    // );
    await Provider.of<UserProvider>(context, listen: false).logout();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IntroPage(),
      ),
    );
  }

  void leave() async {
    Provider.of<UserProvider>(context, listen: false).leave();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IntroPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    ThemeColors themeColors = ThemeColors();
    Size screenSize = MediaQuery.of(context).size;
    double buttonWidth = screenSize.width * 0.8;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ThemeColors.color1,
        title: const Text(
          '프로필',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          const Background(),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: SizedBox(
                  width: 500,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${userProvider.user.nickname}님\n안녕하세요!',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(
                              height: 120,
                              width: 120,
                              child: Image.asset('assets/gifs/chick.gif')),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: buttonWidth,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierColor: Colors.transparent,
                              builder: (BuildContext context) {
                                var mediaQuery = MediaQuery.of(context);
                                var keyboardHeight =
                                    mediaQuery.viewInsets.bottom;

                                return AnimatedPadding(
                                  padding: EdgeInsets.only(
                                      bottom: keyboardHeight), // 키보드 높이만큼 패딩 조정
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dialogBackgroundColor:
                                          const Color(0xFFFFFFFF),
                                      dialogTheme:
                                          const DialogTheme(elevation: 0),
                                    ),
                                    child:
                                        const ChangeNickname(), // 다이얼로그에 표시할 위젯
                                  ),
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.color1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15), // 모서리 둥글기 설정, 숫자를 더 크게 하면 더 둥글게 됩니다.
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8), // 선택적: 패딩 설정
                          ),
                          child: const Text(
                            '닉네임 변경하기',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                        width: buttonWidth,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierColor: Colors.transparent,
                              builder: (BuildContext context) {
                                var mediaQuery = MediaQuery.of(context);
                                var keyboardHeight =
                                    mediaQuery.viewInsets.bottom;

                                return AnimatedPadding(
                                  padding: EdgeInsets.only(
                                      bottom: keyboardHeight *
                                          3 /
                                          5), // 키보드 높이만큼 패딩 조정
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dialogBackgroundColor:
                                          const Color(0xFFFFFFFF),
                                      dialogTheme:
                                          const DialogTheme(elevation: 0),
                                    ),
                                    child:
                                        const ChangePassword(), // 다이얼로그에 표시할 위젯
                                  ),
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.color1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15), // 모서리 둥글기 설정, 숫자를 더 크게 하면 더 둥글게 됩니다.
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8), // 선택적: 패딩 설정
                          ),
                          child: const Text(
                            '비밀번호 변경',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                        width: buttonWidth,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.color1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15), // 모서리 둥글기 설정, 숫자를 더 크게 하면 더 둥글게 됩니다.
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8), // 선택적: 패딩 설정
                          ),
                          child: const Text(
                            '알림 설정하기',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                        width: buttonWidth,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.color2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15), // 모서리 둥글기 설정, 숫자를 더 크게 하면 더 둥글게 됩니다.
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8), // 선택적: 패딩 설정
                          ),
                          child: const Text(
                            '로그아웃',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('주의'),
                                  content: const Text(
                                      '탈퇴하면 일기 등의 모든 정보가 사라져요. 그래도 진행할까요?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('확인'),
                                      onPressed: () {
                                        leave();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('취소'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text(
                            '회원 탈퇴하기',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          )),
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
