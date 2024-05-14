import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();

  void Change() async {
    ApiService apiService = ApiService();
    // await apiService.put(
    //   '/api/member',
    //   data: {
    //     "memberNickname": _nicknameController.text,
    //   },
    // );

    Navigator.pop(context);
    // showDialog(context: context, builder: builder) 비밀번호 성공 확인
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return Center(
      child: SizedBox(
        width: 450,
        height: 320,
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
                    color: themeColors.color1,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextField(
                  controller: _password1Controller,
                  decoration: const InputDecoration(),
                ),
                TextField(
                  controller: _password1Controller,
                  decoration: const InputDecoration(),
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
                          Change();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColors.color1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          '변경하기',
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
                          backgroundColor: themeColors.color2,
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
    );
  }

  @override
  void dispose() {
    _password1Controller.dispose();
    _password2Controller.dispose();
    super.dispose();
  }
}
