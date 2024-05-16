import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ChangeNickname extends StatefulWidget {
  const ChangeNickname({super.key});

  @override
  State<ChangeNickname> createState() => _ChangeNicknameState();
}

class _ChangeNicknameState extends State<ChangeNickname> {
  late TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    // UserProvider에서 사용자의 현재 닉네임을 초기값으로 설정합니다.
    _nicknameController = TextEditingController(
        text: Provider.of<UserProvider>(context, listen: false).user.nickname);
  }

  void updateNickname() async {
    String nickname = _nicknameController.text.trim(); // 공백 제거
    if (nickname.isEmpty) {
      // 닉네임이 비어있으면 사용자에게 알림
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('오류'),
            content: const Text('닉네임은 반드시 1글자 이상이어야 해요.(공백 불가)'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
      return; // 함수 종료
    }

    // 닉네임 업데이트 API 호출
    ApiService apiService = ApiService();
    await apiService.put(
      '/api/member',
      data: {
        "memberNickname": nickname,
      },
    );
    // 사용자 데이터 새로고침
    await Provider.of<UserProvider>(context, listen: false).fetchUserData();
    print(Provider.of<UserProvider>(context, listen: false).user.nickname);
    Navigator.pop(context); // 현재 페이지 닫기
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return Center(
      child: SizedBox(
        width: 450,
        height: 330,
        child: SingleChildScrollView(
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '닉네임 변경하기',
                    style: TextStyle(
                      color: ThemeColors.color1,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(),
                    maxLength: 8, // 사용자 입력을 8자로 제한
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
                            updateNickname();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.color1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15), // 모서리 둥글기 설정, 숫자를 더 크게 하면 더 둥글게 됩니다.
                            ),
                          ),
                          child: const Text(
                            '확인',
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
    _nicknameController.dispose();
    super.dispose();
  }
}
