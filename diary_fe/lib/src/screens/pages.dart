import 'package:diary_fe/src/screens/test1.dart';
import 'package:diary_fe/src/screens/test2.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:diary_fe/src/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스
  late List<Widget> widgetOptions;

  void addWidgets() {
    widgetOptions = [
      const DiaryListPage(),
      const DiaryListPage2(),
      const DiaryListPage(),
      const DiaryListPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    addWidgets();
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // const Background(),
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(
                () {
                  _selectedIndex = index;
                },
              );
            },
            children: widgetOptions,
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {},
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
    );
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // _pageController.animateToPage(
    //   index,
    //   duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
    //   curve: Curves.easeInOut, // 애니메이션 효과
    // );
    _pageController.jumpToPage(index);
  }
}
