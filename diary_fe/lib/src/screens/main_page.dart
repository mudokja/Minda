import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/screens/write_page.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isWrite = false;

  void writeCheck() async {
    ApiService apiService = ApiService();
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Response response =
        await apiService.get('/api/diary/check?diarySetDate=$formattedDate');

    if (response.data == true) {
      setState(() {
        isWrite = true;
      });
    } else {
      setState(() {
        isWrite = false;
      });
    }
  }

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
  void initState() {
    writeCheck();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'high_importance_notification',
              importance: Importance.max,
            ),
          ),
        );
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    ThemeColors themeColors = ThemeColors();

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
                            !isWrite
                                ? Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: '어서오세요 ',
                                              style: TextStyle(
                                                fontSize: 19,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '${userProvider.user.nickname}',
                                              style: TextStyle(
                                                fontSize: 19,
                                                color: themeColors
                                                    .color2, // 변경하고자 하는 글자 색상
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: '님!',
                                              style: TextStyle(
                                                fontSize: 19,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
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
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: '안녕하세요 ',
                                              style: TextStyle(
                                                fontSize: 19,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '${userProvider.user.nickname}',
                                              style: TextStyle(
                                                fontSize: 19,
                                                color: themeColors
                                                    .color2, // 변경하고자 하는 글자 색상
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: '님!',
                                              style: TextStyle(
                                                fontSize: 19,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text(
                                        '오늘은 일기를 작성하셨어요.',
                                        style: TextStyle(
                                          fontSize: 19,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Text(
                                        '분석들을 살펴보고 조언을 받아봐요.',
                                        style: TextStyle(
                                          fontSize: 19,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 50,
                                      ),
                                    ],
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
