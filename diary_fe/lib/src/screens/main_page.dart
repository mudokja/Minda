import 'dart:developer';

import 'package:diary_fe/src/screens/write_page.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void showWritingPage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 모달의 배경을 투명하게 설정
      barrierColor: Colors.transparent, // 뒷 배경을 반투명하게 설정
      builder: (BuildContext context) {
        final Size screenSize = MediaQuery.of(context).size;
        final double modalHeight = screenSize.height * 0.9; // 높이를 화면의 90%로 설정
        final double modalWidth = screenSize.width * 0.9; // 너비를 화면의 90%로 설정

        return Center(
          child: Container(
            width: modalWidth,
            height: modalHeight,
            decoration: BoxDecoration(
              color: Colors.white, // 모달의 배경색을 하얗게 설정
              borderRadius: BorderRadius.circular(25), // 모달의 모서리를 둥글게 설정
            ),
            // child: const Write(), // 여기에 커스텀 위젯을 넣으면 됩니다.
            child: Write(selectedDay: DateTime.now()), // 현재 날짜를 selectedDay로 전달
          ),
        );
      },
    );
  }

  @override
  void initState() async {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Background(),
          SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 500,
                height: 800,
                child: Padding(
                  padding: const EdgeInsets.all(
                      10), // 패딩을 조금 추가하여 화면 너비를 넘지 않도록 합니다.
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: Image.asset('assets/images/main_moon.png'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '어서오세요 ${userProvider.user.nickname}님!',
                              style: const TextStyle(
                                fontSize: 19,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              '오늘 하루는 어떠셨나요?',
                              style: TextStyle(
                                fontSize: 19,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  showWritingPage(context);
                                },
                                child: const Text(
                                  '일기 쓰기',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                            const SizedBox(
                              height: 100,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Image.asset('assets/gifs/rabbit.gif'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
