import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:diary_fe/src/widgets/textform.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _currentpwController = TextEditingController();
  final TextEditingController _pw2Controller = TextEditingController();
  String _pwError = '';
  String _pw2Error = '';
  @override
  void initState() {
    super.initState();

    _pwController.addListener(_validatePassword);
    _pw2Controller.addListener(_validatePasswordConfirmation);
  }

  void _validatePassword() {
    final password = _pwController.text;

    // 정규 표현식: 영문자와 숫자를 각각 하나 이상 포함해야 함
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

    if (password.isEmpty) {
      _setPasswordError(null);
    } else if (!passwordRegex.hasMatch(password)) {
      _setPasswordError('비밀번호는 최소 8자 이상이어야 하며,\n영문자와 숫자를 모두 포함해야 합니다.');
    } else {
      _setPasswordError(null);
    }

    _validatePasswordConfirmation();
  }

  void _validatePasswordConfirmation() {
    final password = _pwController.text;
    final confirmation = _pw2Controller.text;
    if (confirmation.isEmpty) {
      _setPassword2Error(null);
    } else if (password != confirmation) {
      _setPassword2Error('비밀번호가 일치하지 않습니다.');
    } else {
      _setPassword2Error(null);
    }
  }

  void _setPasswordError(String? error) {
    setState(() {
      _pwError = error ?? '';
    });
  }

  void _setPassword2Error(String? error) {
    setState(() {
      _pw2Error = error ?? '';
    });
  }

  void Change() async {
    ApiService apiService = ApiService();

    try {
      await apiService.put('/api/member/auth', data: {
        "memberNewPassword": _pwController.text,
        "memberOldPassword": _currentpwController.text,
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: const Text('비밀번호 변경이 완료되었어요! 다음 로그인부터 새로운 비밀번호로 로그인해주세요.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (e is DioException) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('오류'),
              content: const Text('기존 비밀번호가 잘못 입력되었어요. 확인하고 다시 시도해보세요.'),
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
      }
    }

    // showDialog(context: context, builder: builder) 비밀번호 성공 확인
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return Center(
      child: SizedBox(
        width: 450,
        height: 500,
        child: SingleChildScrollView(
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '새로운 비밀번호 설정',
                    style: TextStyle(
                      color: ThemeColors.color1,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextForm(
                    title: '기존 비밀번호',
                    controller: _currentpwController,
                  ),
                  const SizedBox(height: 15),
                  TextForm(
                    title: '새로운 비밀번호',
                    controller: _pwController,
                    errorText: _pwError.isNotEmpty ? _pwError : null,
                  ),
                  const SizedBox(height: 15),
                  TextForm(
                    title: '비밀번호 확인',
                    controller: _pw2Controller,
                    errorText: _pw2Error.isNotEmpty ? _pw2Error : null,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 75,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_pwError.isEmpty &&
                                _pw2Error.isEmpty &&
                                _pwController.text.isNotEmpty &&
                                _pw2Controller.text.isNotEmpty) {
                              Change();
                            } else {
                              showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('에러 발생'),
                                    content: const SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(
                                              '비밀번호, 비밀번호 확인을 모두 올바르게 입력했는지 확인해보세요.'),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('확인'),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // 다이얼로그 닫기
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.color1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            '변경',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 75,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.color2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15), // 모서리 둥글기 설정, 숫자를 더 크게 하면 더 둥글게 됩니다.
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pwController.removeListener(_validatePassword);
    _pwController.dispose();
    _pw2Controller.removeListener(_validatePasswordConfirmation);
    _pw2Controller.dispose();
    super.dispose();
  }
}
