import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:flutter/material.dart';

class DiaryListPage2 extends StatelessWidget {
  const DiaryListPage2({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColors.color1,
        title: const Text('일기 목록2'),
      ),
      body: const Stack(children: <Widget>[
        Background(),
        Center(
          child: Text(
            '여기는 일기 목록 페이지입니다.',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ]),
    );
  }
}
