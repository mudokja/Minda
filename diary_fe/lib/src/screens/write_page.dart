// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/screens/diary_list_page.dart';
import 'package:diary_fe/src/screens/pages.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String chatbotmessage = '줄바꿈을 할 때마다 저와 대화할 수 있어요!';
  XFile? _image;

////////////////////////
  @override
  void initState() {
    super.initState();
    diaryController.addListener(_handleTextInputChange);

    selectedDate = widget.selectedDay;
  }

  void _handleTextInputChange() {
    String currentText = diaryController.text;
    int newLineIndex = currentText.lastIndexOf('\n');

    // 텍스트가 모두 지워졌다면 lastNewLineIndex 초기화
    if (currentText.isEmpty) {
      lastNewLineIndex = 0;
      return;
    }

    // 현재 텍스트가 이전 텍스트보다 짧아졌는지 확인
    if (currentText.length < lastNewLineIndex) {
      // 줄바꿈 인덱스를 현재 텍스트의 길이로 조정
      lastNewLineIndex = newLineIndex + 1;
    }

    if (newLineIndex > lastNewLineIndex &&
        newLineIndex > 0 &&
        newLineIndex <= currentText.length - 1) {
      if (lastNewLineIndex < currentText.length &&
          newLineIndex > lastNewLineIndex) {
        String lineText =
            currentText.substring(lastNewLineIndex, newLineIndex).trim();
        if (lineText.isNotEmpty) {
          _sendTextToAPI(lineText);
        }
        lastNewLineIndex = newLineIndex + 1;
      }
    }
  }

  Future<void> _sendTextToAPI(String text) async {
    ApiService apiService = ApiService();
    Response response = await apiService.get('/api/ai/chatbot?input=$text');

    if (response.data == '0') {
      setState(() {
        chatbotmessage = '너무 짧은 대화에는 답변할 수 없어요..';
      });
    } else {
      setState(() {
        chatbotmessage = response.data;
      });
    }
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
    try {
      ApiService apiService = ApiService();
      FormData formData = FormData();

      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      String title = titleController.text.isNotEmpty
          ? titleController.text
          : DateFormat('yyyy년 M월 d일의 일기').format(selectedDate);

      var diaryData = {
        "diarySetDate": formattedDate,
        "diaryTitle": title,
        "diaryContent": diaryController.text,
        "hashtagList": [
          "exampleTag1",
        ]
      };

      formData.fields.add(MapEntry("data", json.encode(diaryData)));

      if (_image != null) {
        Uint8List fileBytes = await _image!.readAsBytes();
        MultipartFile multipartFile =
            MultipartFile.fromBytes(fileBytes, filename: "uploaded_file.jpg");
        formData.files.add(MapEntry("imageFiles", multipartFile));
      }

      // API 호출
      Response response = await apiService.post('/api/diary', data: formData);

      setState(() {
        complete = !complete;
      });
    } catch (e) {
      if (e is DioException) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('알림'),
              content: const Text('이미 오늘 일기를 작성했어요!\n(중복 작성이 불가능해요.)'),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> selectImage() async {
    // imageQuality 매개변수 없이 이미지 선택
    if (kIsWeb) {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 25,
      );
      if (pickedFile != null) {
        setState(() {
          // 압축된 이미지로 _image 업데이트
          _image = pickedFile;
        });
      }
    } else {
      if (await Permission.photos
          .onDeniedCallback(() => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('알림'),
                    content: const Text('이미지 삽입을 위해서는 권한 허용이 필요해요.'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('확인'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: const Text('설정 열기'),
                        onPressed: () {
                          openAppSettings();
                        },
                      ),
                    ],
                  );
                },
              ))
          .onPermanentlyDeniedCallback(() {
            return showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('알림'),
                  content: const Text('이미지 삽입을 위해서는 권한 허용이 필요해요.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('확인'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text('설정 열기'),
                      onPressed: () {
                        openAppSettings();
                      },
                    ),
                  ],
                );
              },
            );
          })
          .onLimitedCallback(() {
            return showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('알림'),
                  content: const Text('이미지 삽입을 위해서는 권한 허용이 필요해요.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('확인'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text('설정 열기'),
                      onPressed: () {
                        openAppSettings();
                      },
                    ),
                  ],
                );
              },
            );
          })
          .request()
          .isGranted) {
        final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );

        if (pickedFile != null) {
          // 파일 확장자 검사
          String extension = pickedFile.path.split('.').last.toLowerCase();

          if (extension != 'gif') {
            // GIF가 아닌 경우, 이미지 압축
            final compressedFile =
                await FlutterImageCompress.compressAndGetFile(
              pickedFile.path,
              '${pickedFile.path}_compressed.jpg', // 압축된 이미지 저장 경로
              quality: 25, // 압축 품질
            );

            if (compressedFile != null) {
              setState(() {
                // 압축된 이미지로 _image 업데이트
                _image = XFile(compressedFile.path);
              });
            }
          } else {
            setState(() {
              // GIF 이미지인 경우, 원본 이미지로 _image 업데이트
              _image = pickedFile;
            });
          }
        }
      }
    }
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

  void removeImage() {
    setState(() {
      _image = null;
    });
  }

  List<Widget> _buildCompleteForm(ThemeColors themeColors) {
    Size screenSize = MediaQuery.of(context).size;
    double modalWidth = screenSize.width * 0.9;
    return [
      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              Text(
                '일기 저장이 완료되었어요!',
                style: TextStyle(
                    color: themeColors.color1,
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
                      '작성한 일기 분량에 따라 분석시간이\n조금 소요될 수 있어요.',
                      style: TextStyle(
                          color: themeColors.color1,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '분석이 완료되면 알림을 보내드릴게요!',
                      style: TextStyle(
                          color: themeColors.color1,
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
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Pages(
                                initialPage: 1,
                              )),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColors.color1,
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
            color: themeColors.color1),
      ),
      const SizedBox(height: 15),
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
      const SizedBox(height: 10),
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
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image != null
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: selectImage,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          width: 280,
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: kIsWeb
                                ? Image.network(
                                    _image!.path,
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                  )
                                : Image.file(
                                    File(_image!.path),
                                    fit: BoxFit.cover,
                                    width: 300,
                                    height: 200,
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: themeColors.color1,
                              size: 15,
                            ),
                            onPressed: removeImage,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white, // 배경색을 하얀색으로 설정
                              shape: const CircleBorder(), // 버튼의 모양을 원형으로 설정
                              side: BorderSide(
                                  color: themeColors.color1,
                                  width: 1), // 회색 테두리를 추가
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
          _image == null
              ? SizedBox(
                  width: 120,
                  height: 35,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // 배경색을 투명하게 설정
                      shadowColor: Colors.transparent, // 그림자 제거
                      elevation: 0, // 높이 0으로 설정하여 평면적인 느낌을 줌
                      side: BorderSide(
                          color: themeColors.color1, width: 1), // 파란색 테두리 추가
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)), // 모서리를 둥글게
                    ),
                    onPressed: () {
                      selectImage();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.add_photo_alternate_rounded),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          '이미지 삽입',
                          style: TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
      const SizedBox(
        height: 15,
      ),
      SizedBox(
        width: modalWidth,
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
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      _image != null
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              width: 270,
                              height: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: kIsWeb
                                    ? Image.network(
                                        _image!.path,
                                        fit:
                                            BoxFit.cover, // 이미지가 컨테이너 크기에 맞게 조정
                                        width: 200, // 이미지의 폭을 컨테이너와 동일하게 설정
                                        height: 200, // 이미지의 높이를 컨테이너와 동일하게 설정
                                      )
                                    : Image.file(
                                        File(_image!.path),
                                        fit:
                                            BoxFit.cover, // 이미지가 컨테이너 크기에 맞게 조정
                                        width: 300, // 이미지의 폭을 컨테이너와 동일하게 설정
                                        height: 200, // 이미지의 높이를 컨테이너와 동일하게 설정
                                      ),
                              ),
                            )
                          : const Text('이미지를 넣지 않았어요.'),
                    ],
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9D1DD), // 배경색

                  borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                ),
                child: CustomPaint(
                  painter: LinedPaperPainter(),
                  foregroundPainter:
                      NotebookHolesPainter(24), // 줄 간격으로 구멍 위치 조정
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
