import 'package:diary_fe/src/screens/analysis_page.dart';
import 'package:flutter/material.dart';

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

  DateTime date = DateTime.now();

  void onChangeDate(double num) {
    setState(() {
      if (num > 0) {
        date = date.add(const Duration(days: 1));
      } else if (num < 0) {
        date = date.subtract(const Duration(days: 1));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    calendarView = widget.initialCalendar;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.88,
      child: SegmentedButton<Calendar>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: const Color.fromARGB(255, 189, 105, 212),
          selectedForegroundColor: const Color.fromARGB(255, 230, 230, 230),
          backgroundColor: const Color.fromARGB(255, 230, 230, 230),
          textStyle: const TextStyle(
            fontSize: 18,
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
