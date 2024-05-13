import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/screens/intro_page.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/services/delete_storage.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:diary_fe/src/widgets/change_nickname.dart';
import 'package:flutter/material.dart';
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

  void logout() async {
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeColors.color1,
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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: SizedBox(
                width: 500,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '${userProvider.user.nickname}님\n안녕하세요!',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          width: 80,
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
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  dialogBackgroundColor:
                                      const Color(0xFFFFFFFF),
                                  dialogTheme: const DialogTheme(elevation: 0),
                                ),
                                child: const ChangeNickname(),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColors.color1,
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColors.color1,
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
                          backgroundColor: themeColors.color1,
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
                          backgroundColor: themeColors.color2,
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
                                title: const Text('알림'),
                                content: const Text(
                                    '탈퇴하게 되면 지금까지 작성한 모든 일기가 사라져요. 그래도 진행할까요?'),
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
                                      Navigator.of(context).pop(false);
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
        ],
      ),
    );
  }
}
