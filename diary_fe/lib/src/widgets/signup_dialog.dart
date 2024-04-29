import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/screens/pages.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/widgets/login_dialog.dart';
import 'package:diary_fe/src/widgets/signup_success.dart';
import 'package:diary_fe/src/widgets/textform.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  void verify() {
    if (_formKey.currentState!.validate()) {
      // 유효한 이메일 주소인 경우 인증 로직 수행
    } else {
      // 유효하지 않은 이메일 주소인 경우 경고 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "유효한 이메일 주소를 입력해주세요.",
          ),
        ),
      );
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
        login();
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
      ApiService apiService = ApiService();
      Response response = await apiService.post('/api/auth/login',
          data: {"id": _idController.text, "password": _pwController.text});

      if (response.statusCode == 200) {
        // 가정: 200이 성공 응답 코드
        Map<String, dynamic> responseMap = response.data;
        await storage.write(
            key: "ACCESS_TOKEN", value: responseMap["accessToken"]);
        await storage.write(
            key: "REFRESH_TOKEN", value: responseMap["refreshToken"]);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Pages(),
          ),
        );
      } else {
        // 로그인 실패 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: ${response.data['message']}'),
          ),
        );
      }
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
                      suffix: IconButton(
                        onPressed: () {
                          // verify();
                        },
                        icon: Text(
                          '인증하기',
                          style: TextStyle(color: themeColors.color1),
                        ),
                      ),
                    ),
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
                          if (_formKey.currentState!.validate()) {
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
