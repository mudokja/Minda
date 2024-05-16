import 'dart:developer';

import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:diary_fe/src/widgets/carousel_element.dart';
import 'package:diary_fe/src/widgets/login_dialog.dart';
import 'package:diary_fe/src/widgets/signup_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
    _initFCMToken();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    // 알림 권한 요청
    var notificationStatus = await Permission.notification.request();

    // 파일 권한 요청
    if (kIsWeb) {
    } else {
      var storageStatus2 = await Permission.storage.request();
      var storageStatus1 = await Permission.photos.request();
    }
  }

  void closeApp() {
    // 앱 종료 (Platform-specific implementation)
    if (Theme.of(context).platform == TargetPlatform.android) {
      SystemNavigator.pop();
    }
  }

  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  ThemeColors themeColors = ThemeColors();
  int _currentIndex = 0;
  final CarouselController _controller = CarouselController();
  final List<Widget> imageSliders = [
    const CarouselElement(
        imagePath: 'assets/gifs/thinking_face.gif',
        displayText: '일기를 쓰며 내가 어떤 감정이\n들었는지 궁금하지 않나요?'),
    const CarouselElement(
        imagePath: 'assets/gifs/chart.gif',
        displayText: 'AI 일기 분석을 통해 감정을 통계로\n나타내고 직관적으로 확인해보세요.'),
    const CarouselElement(
        imagePath: 'assets/gifs/clap.gif',
        displayText: '일기를 분석해서 어떤 행동이\n기분에 영향을 주는지 파악하고\n그에 맞는 조언을 해줘요!'),
    const CarouselElement(
        imagePath: 'assets/gifs/eyes.gif',
        displayText: '일기를 쓰고 내가 어떤 감정을\n가지고 있는지 확인해봐요.'),
  ];

  Future<void> _initFCMToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    // 여기에서 _fcmToken을 사용하여 필요한 작업을 수행할 수 있습니다.
    log(fcmToken!); // 로거를 사용하여 토큰을 출력
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Future.microtask(() => {
              if (kIsWeb)
                {const Text('.')}
              else
                {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('알림'),
                        content: const Text('앱을 종료할까요?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(false), // 앱을 종료하지 않음
                            child: const Text('아니요'),
                          ),
                          TextButton(
                            onPressed: () {
                              SystemNavigator.pop(); // 앱 종료
                            },
                            child: const Text('예'),
                          ),
                        ],
                      );
                    },
                  )
                }
            });
      },
      child: Stack(
        children: [
          const Background(),
          Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: CarouselSlider(
                          items: imageSliders,
                          carouselController: _controller,
                          options: CarouselOptions(
                            autoPlay: false,
                            enableInfiniteScroll: false,
                            enlargeCenterPage: true,
                            viewportFraction: 0.9,
                            aspectRatio: 1.5,
                            initialPage: 0,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imageSliders.length, (index) {
                          return Container(
                            width: 20.0,
                            height: 10.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == index
                                  ? themeColors.color1
                                  : themeColors.white,
                            ),
                          );
                        }),
                      ),
                      Column(
                        children: <Widget>[
                          if (_currentIndex == 0 ||
                              _currentIndex == 1 ||
                              _currentIndex == 2) ...[
                            const SizedBox(height: 70),
                            TextButton(
                              onPressed: () {
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
                                '로그인으로 넘어가기',
                                style: TextStyle(
                                  color: themeColors.white,
                                  decorationColor: themeColors.gray,
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 18),
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      themeColors.color1),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // 모서리 둥글기를 30.0으로 설정
                                  ))),
                              onPressed: () {
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
                              child: const Text(
                                '시작해볼까요?',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextButton(
                              onPressed: () {
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
                                '처음 사용해봐요',
                                style: TextStyle(
                                  color: themeColors.white,
                                  decorationColor: themeColors.gray,
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                    ],
                  ),
                  // 왼쪽 화살표 버튼
                  if (_currentIndex > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon:
                            const Icon(Icons.arrow_back_ios_rounded, size: 30),
                        color: themeColors.white,
                        onPressed: () => _controller.previousPage(),
                      ),
                    ),
                  // 오른쪽 화살표 버튼 위치 조정
                  if (_currentIndex < imageSliders.length - 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 30),
                        color: themeColors.white,
                        onPressed: () => _controller.nextPage(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
