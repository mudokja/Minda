import 'package:diary_fe/src/screens/select_analysis_page.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'package:diary_fe/src/widgets/single_choice_button.dart';
import 'package:flutter/material.dart';

enum Calendar { day, week, month, custom }

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  Calendar calendarView = Calendar.day;

  void updateCalendarView(Calendar newCalendar) {
    setState(() {
      calendarView = newCalendar;
    });
  }

  Widget buildAnalysisPage() {
    switch (calendarView) {
      case Calendar.day:
        return const DayAnalysisPage();
      case Calendar.week:
        return const WeekAnalysisPage();
      case Calendar.month:
        return const MonthAnalysisPage();
      case Calendar.custom:
        return const CustomAnalysisPage();
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
