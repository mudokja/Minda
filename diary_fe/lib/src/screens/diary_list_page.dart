import 'package:diary_fe/constants.dart'; // 이 부분은 실제 경로에 맞게 조정해주세요.
import 'package:diary_fe/src/widgets/background.dart'; // 이 부분은 실제 경로에 맞게 조정해주세요.
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryListPage extends StatelessWidget {
  const DiaryListPage({super.key});

  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          width: double.maxFinite,
          child: TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: DateTime.now(),
            selectedDayPredicate: (day) => false,
            onDaySelected: (selectedDay, focusedDay) {
              Navigator.pop(context);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return Image.asset(
                  'assets/icon/white_calendar.png',
                  width: 24,
                  height: 24,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '일기장',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Background(), // Background 위젯의 정확한 구현을 확인해주세요.
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          _showCalendarDialog(context);
                        },
                        icon: Image.asset(
                          'assets/icon/white_calendar.png',
                          width: 45,
                          height: 45,
                        ),
                      ),
                      SizedBox(width: 13),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '제목/내용',
                            fillColor: Colors.transparent,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0).copyWith(left: 20.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.white, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.white, width: 3.0),
                            ),
                            hintStyle: TextStyle(color: Colors.white),
                            suffixIcon: Icon(Icons.search_rounded, color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 다른 위젯들 추가
              ],
            ),
          ),
        ],
      ),
    );
  }
}
