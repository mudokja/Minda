import 'dart:async';

import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/screens/pages.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:diary_fe/src/widgets/login_dialog.dart';
import 'package:diary_fe/src/widgets/signup_success.dart';
import 'package:diary_fe/src/widgets/textform.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class SignUpModal extends StatefulWidget {
  const SignUpModal({super.key});

  @override
  State<SignUpModal> createState() => _SignUpModalState();
}

class _SignUpModalState extends State<SignUpModal> {
  final storage = const FlutterSecureStorage();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pw2Controller = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  bool _isVerified = false; // 이메일 인증 성공 여부
  Timer? _timer; // 타이머
  int _remainingTime = 300; // 초 단위, 5분
  bool _isCodeSent = false;
  String verificationId = '';
  void verifyEmail() async {
    try {
      // 인증 코드 발송 요청 로직 구현
      // 예제는 서버에 요청하는 로직이 들어가야 합니다.
      ApiService apiService = ApiService();
      Response response = await apiService.post(
        '/api/email/verification',
        data: {
          "email": _emailController.text,
        },
      );

      if (response.statusCode == 200) {
        _timer?.cancel();
        setState(() {
          _isCodeSent = true;
          verificationId = response.data["verificationId"];
          startTimer();
        });
        // 인증 코드 발송 성공 메시지 또는 로직
      } else {
        // 인증 코드 발송 실패 처리
      }
    } catch (e) {
      // 에러 처리
    }
  }

  void startTimer() {
    setState(() {
      _remainingTime = 300; // 초 단위, 5분
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _timer?.cancel();
        const Text('시간이 초과되었습니다.');
      }
    });
  }

  void confirmVerification() async {
    // 인증 코드 확인 로직
    ApiService apiService = ApiService();
    Response response = await apiService.post(
      '/api/email/auth',
      data: {
        "verificationId": verificationId,
        "code": _verificationCodeController.text
      },
    );
    if (response.statusCode == 200) {
      _timer?.cancel();
      setState(() {
        _isVerified = true;
      });
    }
  }

  void signUp() async {
    try {
      ApiService apiService = ApiService();
      Response response = await apiService.post(
        '/api/member/register',
        data: {
          "id": _idController.text,
          "password": _pwController.text,
          "nickname": _nicknameController.text,
          "email": _emailController.text,
        },
      );
      print(response.statusCode);

      if (response.statusCode == 201) {
        await login();
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          builder: (BuildContext context) {
            return Theme(
              data: Theme.of(context).copyWith(
                dialogBackgroundColor: const Color(0xFFFFFFFF),
                dialogTheme: const DialogTheme(elevation: 0),
              ),
              child: const SignUpSuccess(),
            );
          },
        );
      } else {
        // // 회원가입 실패 처리
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('회원가입 실패: ${response.data['message']}'),
        //   ),
        // );
      }
    } catch (e) {
      print(e);
      // 네트워크 오류 등의 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입 중 오류가 발생했습니다.'),
        ),
      );
    }
  }

  Future<void> login() async {
    try {
      _timer?.cancel();
      ApiService apiService = ApiService();
      Response response = await apiService.post('/api/auth/login',
          data: {"id": _idController.text, "password": _pwController.text});
      Map<String, dynamic> responseMap = response.data;
      await storage.write(
          key: "ACCESS_TOKEN", value: responseMap["accessToken"]);
      await storage.write(
          key: "REFRESH_TOKEN", value: responseMap["refreshToken"]);
      Provider.of<UserProvider>(context, listen: false).fetchUserData();
    } catch (e) {
      print(e);
      // 로그인 과정 중 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 중 오류가 발생했습니다.'),
        ),
      );
    }
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '회원가입하기',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: themeColors.color1,
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextForm(
                      title: '아이디',
                      controller: _idController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '아이디를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextForm(
                      title: '이메일',
                      controller: _emailController,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            _isVerified == false) {
                          return '이메일 인증을 진행해주세요';
                        }
                        return null;
                      },
                      suffix: IconButton(
                        onPressed: () {
                          verifyEmail();
                        },
                        icon: Text(
                          '인증하기',
                          style: TextStyle(color: themeColors.color1),
                        ),
                      ),
                    ),
                    if (_isCodeSent) ...[
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: TextForm(
                                  title: '이메일 인증 코드',
                                  controller: _verificationCodeController,
                                  suffix: IconButton(
                                    onPressed: confirmVerification,
                                    icon: Text(
                                      '확인',
                                      style:
                                          TextStyle(color: themeColors.color1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                flex: 1,
                                child: _isVerified
                                    ? const Text(
                                        '확인되었습니다.',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 8,
                                        ),
                                      )
                                    : Text(
                                        "${(_remainingTime / 60).floor().toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}"),
                              ),
                            ],
                          ),
                          // if (_isVerified)
                          //   const Text(
                          //     '확인되었습니다.',
                          //     style: TextStyle(color: Colors.green),
                          //   ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextForm(
                      title: '비밀번호',
                      controller: _pwController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        } else if (!RegExp(
                                r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$')
                            .hasMatch(value)) {
                          return '비밀번호는 8자 이상이며, 숫자와 영문자를\n포함해야 합니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextForm(
                      title: '비밀번호 확인',
                      controller: _pw2Controller,
                      validator: (value) {
                        if (value != _pwController.text) {
                          return '비밀번호가 일치하지 않습니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextForm(
                      title: '닉네임',
                      controller: _nicknameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '닉네임을 입력해주세요';
                        } else if (value.length > 8) {
                          return '닉네임은 최대 8글자까지 가능합니다.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              _isVerified) {
                            signUp();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColors.color1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '가입하기',
                          style: TextStyle(
                            color: themeColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                dialogBackgroundColor: const Color(0xFFFFFFFF),
                                dialogTheme: const DialogTheme(elevation: 0),
                              ),
                              child: const LoginModal(),
                            );
                          },
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '계정이 있으신가요?',
                            style: TextStyle(
                              fontSize: 13,
                              color: themeColors.color1,
                              fontWeight: FontWeight.w600,
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
                                    child: const LoginModal(),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
