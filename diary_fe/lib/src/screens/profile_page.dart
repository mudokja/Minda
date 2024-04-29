import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.all(40),
            child: Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        '삐약쓰님\n안녕하세요!',
                        style: TextStyle(
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
                    height: 100,
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
                      onPressed: () {},
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
                    height: 60,
                  ),
                  const Text(
                    '회원 탈퇴하기',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
