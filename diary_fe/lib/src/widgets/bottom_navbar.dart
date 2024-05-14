import 'package:flutter/material.dart';
import 'package:diary_fe/constants.dart'; // ThemeColors 정의 포함

class BottomNavbar extends StatelessWidget {
  final int currentIndex; // 현재 선택된 인덱스
  final Function(int) onItemTapped; // 탭 변경 시 호출될 콜백

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: const Color(0xFFD898C8),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildTabItem(
            imagePath: "assets/images/home.png",
            label: '메인',
            index: 0,
            themeColors: themeColors,
            isSelected: currentIndex == 0,
            onTap: onItemTapped,
          ),
          _buildTabItem(
            imagePath: "assets/images/diary.png",
            label: '일기 목록',
            index: 1,
            themeColors: themeColors,
            isSelected: currentIndex == 1,
            onTap: onItemTapped,
          ),
          const SizedBox(width: 48), // FloatingActionButton을 위한 공간
          _buildTabItem(
            imagePath: "assets/images/statistics.png",
            label: '일기 통계',
            index: 2,
            themeColors: themeColors,
            isSelected: currentIndex == 2,
            onTap: onItemTapped,
          ),
          _buildTabItem(
            imagePath: "assets/images/settings.png",
            label: '설정',
            index: 3,
            themeColors: themeColors,
            isSelected: currentIndex == 3,
            onTap: onItemTapped,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String imagePath,
    required String label,
    required int index,
    required ThemeColors themeColors,
    required bool isSelected,
    required Function(int) onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            imagePath,
            width: 30,
            height: 30,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? ThemeColors.color1 : ThemeColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
