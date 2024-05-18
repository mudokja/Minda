import 'package:flutter/material.dart';
import 'package:diary_fe/src/screens/analysis_page.dart'; // 필요한 경우 정확한 경로를 사용하세요.

class SingleChoice extends StatefulWidget {
  final Calendar initialCalendar;
  final Function(Calendar) onUpdateCalendarView;

  const SingleChoice({
    super.key,
    required this.initialCalendar,
    required this.onUpdateCalendarView,
  });

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  late Calendar calendarView;

  @override
  void initState() {
    super.initState();
    calendarView = widget.initialCalendar;
  }

  @override
  void didUpdateWidget(covariant SingleChoice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCalendar != widget.initialCalendar) {
      setState(() {
        calendarView = widget.initialCalendar;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 400 ? 13.0 : 16.0;
    final buttonWidth = screenWidth * 0.88;

    return SizedBox(
      width: buttonWidth,
      child: SegmentedButton<Calendar>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: const Color.fromARGB(255, 189, 105, 212),
          selectedForegroundColor: const Color.fromARGB(255, 230, 230, 230),
          backgroundColor: const Color.fromARGB(255, 230, 230, 230),
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
          side: const BorderSide(
            color: Colors.transparent,
          ),
        ),
        showSelectedIcon: false,
        segments: const <ButtonSegment<Calendar>>[
          ButtonSegment<Calendar>(
            value: Calendar.day,
            label: Text('일간'),
          ),
          ButtonSegment<Calendar>(
            value: Calendar.week,
            label: Text('주간'),
          ),
          ButtonSegment<Calendar>(
            value: Calendar.month,
            label: Text('월간'),
          ),
          ButtonSegment<Calendar>(
            value: Calendar.custom,
            label: Text('직접입력'),
          ),
        ],
        selected: {calendarView},
        onSelectionChanged: (Set<Calendar> newSelection) {
          setState(() {
            calendarView = newSelection.first;
          });
          widget.onUpdateCalendarView(calendarView);
        },
      ),
    );
  }
}
