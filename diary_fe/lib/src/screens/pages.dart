import 'package:diary_fe/src/screens/analysis_page.dart';
import 'package:diary_fe/src/screens/diary_list_page.dart';
import 'package:diary_fe/src/screens/main_page.dart';
import 'package:diary_fe/src/screens/profile_page.dart';
import 'package:diary_fe/src/screens/test2.dart';
import 'package:diary_fe/src/screens/write_page.dart';
import 'package:diary_fe/src/widgets/bottom_navbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Pages extends StatefulWidget {
  final int initialPage;

  const Pages({super.key, this.initialPage = 0});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  late final PageController _pageController;
   late int _selectedIndex;
  late List<Widget> widgetOptions;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPage;  // 초기 페이지 인덱스 설정
    _pageController = PageController(initialPage: widget.initialPage);
  }

  void addWidgets() {
    widgetOptions = [
      const MainPage(),
      DiaryListPage(selectedDay: DateTime.now()), // 오늘 날짜를 기본값으로 설정
      const AnalysisPage(),
      const ProfilePage(),
    ];
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
            child:
                // const Write(), // 여기에 커스텀 위젯을 넣으면 됩니다.
                // const Write({super.key, required this.selectedDay}),
                Write(selectedDay: DateTime.now()), // 현재 날짜를 selectedDay로 전달
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    addWidgets();
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
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(
              () {
                _selectedIndex = index;
              },
            );
          },
          physics: const AlwaysScrollableScrollPhysics(),
          children: widgetOptions,
        ),
        floatingActionButton: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: () {
              showWritingPage(context);
            },
            shape: const StadiumBorder(),
            backgroundColor: Colors.white,
            child: Image.asset(
              'assets/images/write.png',
              width: 50,
              height: 50,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavbar(
            currentIndex: _selectedIndex, onItemTapped: onItemTapped),
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.jumpToPage(index);
  }
}
