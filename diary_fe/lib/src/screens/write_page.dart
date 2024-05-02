// ignore_for_file: depend_on_referenced_packages

import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Write extends StatefulWidget {
  const Write({super.key});

  @override
  State<Write> createState() => _WriteState();
}

class NotebookHolesPainter extends CustomPainter {
  final double lineSpacing;

  NotebookHolesPainter(this.lineSpacing);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    double holeRadius = 5;
    double xOffset = 20; // 공책 구멍의 x 축 위치

    // 줄마다 구멍을 그립니다.
    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawCircle(Offset(xOffset, y), holeRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LinedPaperPainter extends CustomPainter {
  final double lineSpacing = 24;
  final double horizontalPadding = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;
    double dashWidth = 5.0;
    double dashSpace = 5.0;

    for (double i = lineSpacing; i < size.height; i += lineSpacing) {
      double x = horizontalPadding; // 패딩을 적용한 시작점
      while (x < size.width - horizontalPadding) {
        // 패딩을 적용한 끝점까지 그립니다.
        canvas.drawLine(Offset(x, i), Offset(x + dashWidth, i), paint);
        x += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _WriteState extends State<Write> {
  DateTime selectedDate = DateTime.now();
  TextEditingController diaryController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  bool showConfirmation = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked.isAfter(DateTime.now()) ? DateTime.now() : picked;
      });
    }
  }

  void _toggleConfirmationView() {
    setState(() {
      showConfirmation = !showConfirmation;
    });
  }

  Future<void> sendContent() async {
    ApiService apiService = ApiService();
    FormData formData = FormData();
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    String title = titleController.text.isNotEmpty
        ? titleController.text
        : DateFormat('yyyy년 M월 d일의 일기').format(selectedDate); // 제목이 비었을 때의 로직

    // FormData 필드 추가
    formData.fields.add(MapEntry("diarySetDate", formattedDate));
    formData.fields.add(MapEntry("diaryTitle", title));
    formData.fields.add(MapEntry("diaryContent", diaryController.text));

    print(formData.fields);
    await apiService.post('/api/diary', data: formData);
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!showConfirmation) ..._buildDiaryEntryForm(themeColors),
              if (showConfirmation) ..._buildDiaryConfirmationView(themeColors),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDiaryEntryForm(ThemeColors themeColors) {
    Size screenSize = MediaQuery.of(context).size;
    double modalHeight = screenSize.height * 0.9;
    double modalWidth = screenSize.width * 0.9;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.keyboard_arrow_down,
                color: Colors.grey, size: 30),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          InkWell(
            onTap: () => _selectDate(context),
            child: const Icon(Icons.calendar_month),
          ),
          const SizedBox(width: 30),
          Text(
            "${selectedDate.toLocal()}".split(' ')[0],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      const SizedBox(height: 15),
      Text(
        '오늘은 어떤일이 있었나요?',
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: themeColors.color1),
      ),
      const SizedBox(height: 15),
      TextField(
        controller: titleController,
        decoration: InputDecoration(
          hintText: '제목',
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: themeColors.color2,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      SingleChildScrollView(
        child: SizedBox(
          height: keyboardHeight == 0
              ? modalHeight / 2
              : modalHeight / 2 - keyboardHeight * 2 / 3,
          child: TextField(
            controller: diaryController,
            decoration: const InputDecoration(
              hintText: '자유롭게 일기를 작성해보세요.',
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            textInputAction: TextInputAction.newline,
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      SizedBox(
        width: modalWidth * 0.8,
        child: ElevatedButton(
          onPressed: _toggleConfirmationView,
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColors.color1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            '완료',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildDiaryConfirmationView(ThemeColors themeColors) {
    Size screenSize = MediaQuery.of(context).size;
    // double modalHeight = screenSize.height * 0.9;
    double modalWidth = screenSize.width * 0.9;
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.keyboard_arrow_down,
                color: Colors.grey, size: 30),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '작성된 일기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: themeColors.color2,
                  ),
                ),
                SizedBox(
                  width: 80, // 너비를 늘림
                  height: 40, // 높이를 늘림
                  child: TextButton(
                    onPressed: _toggleConfirmationView,
                    child: Text(
                      '수정하기',
                      style: TextStyle(
                          color: themeColors.color1,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9D1DD), // 배경색

              borderRadius: BorderRadius.circular(8), // 모서리 둥글게
            ),
            child: CustomPaint(
              painter: LinedPaperPainter(),
              foregroundPainter: NotebookHolesPainter(24), // 줄 간격으로 구멍 위치 조정
              child: SizedBox(
                width: modalWidth,
                height: 400, // 적절한 높이 지정
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          titleController.text.isNotEmpty
                              ? titleController.text
                              : '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일의 일기',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          diaryController.text.isNotEmpty
                              ? diaryController.text
                              : '일기가 작성되지 않았어요..',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFFA488AF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 70),
      SizedBox(
        width: modalWidth * 0.9,
        child: ElevatedButton(
          onPressed: diaryController.text.isNotEmpty
              ? () {
                  sendContent();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColors.color1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            '일기 저장 및 분석하기',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      const SizedBox(height: 30),
      Center(
        child: Text(
          '⚠️ 주의 : 창을 닫으면 작성했던 일기가 모두 사라져요!',
          style: TextStyle(fontSize: 10, color: themeColors.color2),
        ),
      ),
    ];
  }
}
