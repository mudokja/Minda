
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:diary_fe/src/widgets/color_legend_toggle.dart';
import 'dart:math';
// import 'package:diary_fe/src/screens/diary_list_page.dart';
import 'package:diary_fe/src/widgets/diary_detail_page.dart';


import 'package:diary_fe/src/services/diary_provider.dart';

class CalendarDialog {
  static void showCalendarDialog(BuildContext context) {
    final List<Color> colors = [
      const Color(0xFFF5AC25), // 기쁨에 노랑
      const Color(0xFFFC819E), // 놀람에 핑크
      const Color(0xFFB3B4B4), // 불안에 회색
      const Color(0xFFBC7FCD), // 슬픔에 연보라
      const Color(0xFF86469C), // 상처에 진보라
      const Color(0xFFDF1E1E), // 분노에 빨강
    ];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        // SizedBox의 높이를 증가시켜 색상 설명을 포함할 공간을 확보합니다.
        height: 510,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column의 크기를 내용물에 맞춥니다.
          children: [
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
                selectedDayPredicate: (day) => false,
                onDaySelected: (selectedDay, focusedDay) {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryListPage(selectedDay: selectedDay),
                    ),
                  );
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final randomIndex = Random().nextInt(colors.length);
                    // 생성된 랜덤 인덱스를 사용하여 색상 선택
                    final color = colors[randomIndex];

                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.7), // 랜덤 색상 적용
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.day.toString(),
                        // style: TextStyle(color: color, fontSize: 24),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    // 오늘 날짜에 대한 커스텀 디자인
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent, // 배경을 투명하게 설정
                        border: Border.all(
                            color: const Color.fromARGB(
                                255, 240, 105, 161)), // 검은색 테두리
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.day.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ), // 텍스트 색상을 검은색으로 설정
                      ),
                    );
                  },
                ),
              ),
            ),
            // 색상 설명 추가(토글로..)
            const ColorLegendToggle(), // 토글 위젯 추가
            ],
          ),
        ),
      ),
    );
  }
}