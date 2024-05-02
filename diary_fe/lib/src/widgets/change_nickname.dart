import 'package:diary_fe/src/services/user_provider.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(),
            maxLength: 8, // 사용자 입력을 8자로 제한
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 닉네임 업데이트 로직 구현
            },
            child: const Text('변경하기'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
}
