import 'dart:developer';

import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/screens/pages.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:diary_fe/src/widgets/signup_dialog.dart';
import 'package:diary_fe/src/widgets/textform.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class LoginModal extends StatefulWidget {
  const LoginModal({super.key});

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _isButtonEnabled = true;
  final storage = const FlutterSecureStorage();
  Future<void> login() async {
    if (_idController.text.isEmpty || _pwController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: const Text('아이디와 비밀번호를 모두 입력해야 해요.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
      return;
    }
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .login(_idController.text, _pwController.text);
      await Provider.of<UserProvider>(context, listen: false).fetchUserData();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Pages(),
          ));
    } catch (e) {
      if (e is DioException) {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // 다이얼로그 바깥을 터치해도 닫히지 않도록 설정
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('로그인 오류'),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('회원가입이 되어있지 않거나, 아이디나 \n비밀번호가 달라요.'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _handleButtonClick() {
    setState(() {
      _isButtonEnabled = false; // 버튼 비활성화
    });
    login();

    // 2초 후에 버튼을 다시 활성화
    Future.delayed(const Duration(microseconds: 500), () {
      setState(() {
        _isButtonEnabled = true; // 버튼 활성화
      });
    });
  }

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
                    '로그인',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: themeColors.color1),
                  ),
                  const SizedBox(height: 25), // 간격 추가
                  TextForm(title: '아이디', controller: _idController),
                  const SizedBox(height: 20), // 간격 추가
                  TextForm(title: '비밀번호', controller: _pwController),

                  const SizedBox(height: 30), // 간격 추가
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled ? _handleButtonClick : null,
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

                  const SizedBox(height: 20), // 간격 추가
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '아직 계정이 없으신가요?',
                          style: TextStyle(
                            fontSize: 13,
                            color: themeColors.color1,
                            fontWeight: FontWeight.w600,
                            // 밑줄
                          ),
                        ),
                        const SizedBox(
                          width: 1,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    dialogBackgroundColor:
                                        const Color(0xFFFFFFFF),
                                    dialogTheme:
                                        const DialogTheme(elevation: 0),
                                  ),
                                  child: const SignUpModal(),
                                );
                              },
                            );
                          },
                          child: Text(
                            '여기를 클릭하세요!',
                            style: TextStyle(
                              fontSize: 13,
                              color: themeColors.color2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                              right: 10.0), // 텍스트와의 간격을 주기 위해 마진 설정
                          child: Divider(
                            color: themeColors.color1, // 선의 색상
                            height: 1.5, // Divider의 높이를 설정
                          ),
                        ),
                      ),
                      Text(
                        "간편로그인",
                        style: TextStyle(
                          color: themeColors.color1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 10.0), // 텍스트와의 간격을 주기 위해 마진 설정
                          child: Divider(
                            color: themeColors.color1, // 선의 색상

                            height: 1.5, // Divider의 높이를 설정
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    child: Ink.image(
                      image: const AssetImage('assets/images/kakao.png'),
                      fit: BoxFit.cover, // 이미지 채우기 방식 지정
                      width: 200,
                      height: 40,
                      child: InkWell(
                        onTap: () async {
                          await Provider.of<UserProvider>(context,
                                  listen: false)
                              .kakaoLogin();
                          await Provider.of<UserProvider>(context,
                                  listen: false)
                              .fetchUserData();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Pages(),
                            ),
                          );
                        },

                        // InkWell이 꽉 찬 영역에 반응하도록 Container 등으로 감싸거나 크기를 지정
                        child: const SizedBox(
                          width: 500, // InkWell의 크기를 지정
                          height: 60,
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
