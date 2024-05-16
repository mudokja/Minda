import 'package:diary_fe/src/screens/select_analysis_page.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:diary_fe/src/widgets/single_choice_button.dart';
import 'package:flutter/material.dart';

enum Calendar { day, week, month, custom }

class AnalysisPage extends StatefulWidget {
  final DateTime? selectedDate;
  const AnalysisPage({
    super.key,
    this.selectedDate,
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late Calendar calendarView;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    calendarView = Calendar.day;
    selectedDate = widget.selectedDate ?? DateTime.now();
  }

  void updateCalendarView(Calendar newCalendar) {
    setState(() {
      calendarView = newCalendar;
    });
  }

  void updateSelectedDate(DateTime date) {
    setState(() {
      selectedDate = date;
      calendarView = Calendar.day;
    });
  }

  Widget buildAnalysisPage() {
    switch (calendarView) {
      case Calendar.day:
        return DayAnalysisPage(
          date: selectedDate,
          onDateSelected: updateSelectedDate,
        );
      case Calendar.week:
        return WeekAnalysisPage(
          onDateSelected: updateSelectedDate,
        );
      case Calendar.month:
        return MonthAnalysisPage(
          onDateSelected: updateSelectedDate,
        );
      case Calendar.custom:
        return CustomAnalysisPage(
          onDateSelected: updateSelectedDate,
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Background(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 30,
                horizontal: 20,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      SingleChoice(
                        onUpdateCalendarView: updateCalendarView,
                        initialCalendar: calendarView,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      buildAnalysisPage(),
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
