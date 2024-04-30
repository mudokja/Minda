import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/screens/pages.dart';
import 'package:flutter/material.dart';

class SignUpSuccess extends StatefulWidget {
  const SignUpSuccess({super.key});

  @override
  State<SignUpSuccess> createState() => _LoginModalState();
}

class _LoginModalState extends State<SignUpSuccess> {
  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          backgroundColor: const Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SizedBox(
            width: 380,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 모달 컨텐츠 크기에 맞게 조절
                children: <Widget>[
                  Text(
                    '회원가입이 완료 되었어요!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: themeColors.color1),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '서비스를 이용하러 가볼까요?',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: themeColors.color1),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    'assets/gifs/party_popper.gif',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(
                    height: 70,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Pages(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColors.color1, // 버튼 색상
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '로그인',
                        style: TextStyle(
                          color: themeColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
