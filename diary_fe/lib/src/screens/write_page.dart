// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';

import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Write extends StatefulWidget {
  // const Write({super.key});
  final DateTime selectedDay; // selectedDay 정의

  const Write(
      {super.key, required this.selectedDay}); // 생성자를 통해 selectedDay를 받음

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
  bool complete = false;
  int lastNewLineIndex = 0;
  Timer? _debounce;
  String lastContent ='';
  String chatbotmessage = '줄바꿈을 할 때마다 저와 대화할 수 있어요!';

////////////////////////
  @override
  void initState() {
    super.initState();
    diaryController.addListener(_handleTextInputChange);
    selectedDate = widget.selectedDay; // 페이지를 열 때 전달받은 날짜를 사용
  }

  void _handleTextInputChange() {
    print("값치환 ${diaryController.value.composing} : start ${diaryController.selection.start} : end ${diaryController.selection.end} : test ${diaryController.value.isComposingRangeValid} \n value : ${diaryController.value} \n composing ${diaryController.value.composing} \n char : ${diaryController.text.characters} \n unit: ${diaryController.text.codeUnits} \n rune : ${diaryController.text.runes}");
    if (_debounce?.isActive ?? false) {diaryController.value = diaryController.value.copyWith(
      text: lastContent,
      selection:
      TextSelection(baseOffset: lastContent.length, extentOffset: lastContent.length),
      composing: TextRange.empty,
    );}else{

    String currentText = diaryController.text;
    int newLineIndex = currentText.lastIndexOf('\n');
    // 새로운 줄바꿈 인덱스가 마지막 인덱스보다 큰지 확인하고, 유효한 인덱스인지 검사
    if (newLineIndex > lastNewLineIndex &&
        newLineIndex > 0 &&
        newLineIndex <= currentText.length - 1) {
      // 문자열 추출 전에 인덱스가 유효한지 확인
      if (lastNewLineIndex < currentText.length &&
          newLineIndex > lastNewLineIndex) {
        String lineText =
            currentText.substring(lastNewLineIndex, newLineIndex).trim();
        if (lineText.isNotEmpty) {
          _sendTextToAPI(lineText);
        }
        lastNewLineIndex = newLineIndex + 1; // 줄바꿈 문자 다음 위치를 저장
      }
    }
    lastContent=diaryController.text;
    _debounce = Timer(const Duration(milliseconds: 1), () {
      print("지연 종료");
    });
    }
  }

  Future<void> _sendTextToAPI(String text) async {
    // 여기에 API 요청 로직을 구현하세요.

    ApiService apiService = ApiService();
    Response response = await apiService.get('/api/ai/chatbot?input=$text');
    print(response.data);
    if (response.data == '0') {
      setState(() {
        chatbotmessage = '너무 짧은 대화에는 답변할 수 없어요..';
      });
    } else {
      setState(() {
        chatbotmessage = response.data;
      });
    }

    // 예를 들어, HTTP 클라이언트를 사용한 요청:
    // final response = await http.post('https://your.api.url/diary', body: {'text': text});
    // print('Response status: ${response.statusCode}');
  }

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
        : DateFormat('yyyy년 M월 d일의 일기').format(selectedDate);

    // diaryAddRequestDto 객체 생성
    var diaryData = {
      "diarySetDate": formattedDate,
      "diaryTitle": title,
      "diaryContent": diaryController.text,
      "hashtagList": [
        "exampleTag1", // 예시 태그, 실제 사용 시 적절한 데이터로 교체
      ]
    };
    // diaryAddRequestDto JSON 객체를 FormData에 추가
    formData.fields.add(MapEntry("data", json.encode(diaryData)));

    formData.fields.add(const MapEntry("imageFiles", "string"));

    // API 호출
    Response response = await apiService.post('/api/diary', data: formData);

    setState(() {
      complete = !complete;
    });
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
              if (!showConfirmation && !complete)
                ..._buildDiaryEntryForm(themeColors),
              if (showConfirmation && !complete)
                ..._buildDiaryConfirmationView(themeColors),
              if (showConfirmation && complete)
                ..._buildCompleteForm(themeColors),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCompleteForm(ThemeColors themeColors) {
    Size screenSize = MediaQuery.of(context).size;
    double modalWidth = screenSize.width * 0.9;
    return [
      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              Text(
                '일기 저장이 완료되었어요!',
                style: TextStyle(
                    color: ThemeColors.color1,
                    fontSize: 25,
                    fontWeight: FontWeight.w600),
              ),
              Image.asset('assets/gifs/analyze2.gif'),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '작성한 일기 분량에 따라 분석시간이 조금 소요될 수 있어요.',
                      style: TextStyle(
                          color: ThemeColors.color1,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '분석이 완료되면 알림을 보내드릴게요!',
                      style: TextStyle(
                          color: ThemeColors.color1,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 90,
              ),
              SizedBox(
                width: modalWidth * 0.9,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.color1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    ];
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
            color: ThemeColors.color1),
      ),
      const SizedBox(height: 15),
      TextField(
        controller: titleController,
        decoration: InputDecoration(
          hintText: '제목',
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: ThemeColors.color2,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      SingleChildScrollView(
        child: SizedBox(
          height: keyboardHeight == 0
              ? modalHeight * 2 / 5
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
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[200], // 밝은 회색 배경색 설정

          borderRadius: BorderRadius.circular(12), // 모서리 둥글게 만들기
        ),
        padding: const EdgeInsets.all(8.0), // 내부 패딩을 넣어 테두리와 콘텐츠 사이 간격을 줌
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Image.asset('assets/gifs/chick.gif'),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                chatbotmessage,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      SizedBox(
        width: modalWidth,
        child: ElevatedButton(
          onPressed: _toggleConfirmationView,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.color1,
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
                    color: ThemeColors.color2,
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
                          color: ThemeColors.color1,
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
            backgroundColor: ThemeColors.color1,
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
          style: TextStyle(fontSize: 10, color: ThemeColors.color2),
        ),
      ),
    ];
  }
}
