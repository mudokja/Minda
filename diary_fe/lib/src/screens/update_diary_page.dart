import 'package:flutter/material.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/widgets/background.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';

class UpdateDiaryPage extends StatefulWidget {
  final int diaryIndex;
  final String diaryTitle;
  final String diaryContent;
  final DateTime initialSelectedDay;

  const UpdateDiaryPage({
    super.key,
    required this.diaryIndex,
    required this.diaryTitle,
    required this.diaryContent,
    required this.initialSelectedDay,
  });

  @override
  State<UpdateDiaryPage> createState() => _UpdateDiaryPageState();
}

class _UpdateDiaryPageState extends State<UpdateDiaryPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  late DateTime selectedDay;
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    titleController.text = widget.diaryTitle;
    contentController.text = widget.diaryContent;
    selectedDay = widget.initialSelectedDay;
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((image) => File(image.path)).toList();
      });
    }
  }

  Future<void> updateDiary() async {
    try {
      ApiService apiService = ApiService();
      FormData formData = FormData();

      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay);

      String title = titleController.text.isNotEmpty
          ? titleController.text
          : (widget.diaryTitle.isNotEmpty
              ? widget.diaryTitle
              : DateFormat('yyyy년 M월 d일의 일기').format(selectedDay));

      String content = contentController.text.isNotEmpty
          ? contentController.text
          : (widget.diaryContent.isNotEmpty
              ? widget.diaryContent
              : '내용이 없습니다.');

      var diaryData = {
        "diaryIndex": widget.diaryIndex,
        "diaryTitle": title,
        "diaryContent": content,
        "hashtagList": []
      };

      formData.fields.add(MapEntry("data", json.encode(diaryData)));

      if (_selectedImages.isNotEmpty) {
        for (var image in _selectedImages) {
          Uint8List fileBytes = await image.readAsBytes();
          MultipartFile multipartFile = MultipartFile.fromBytes(fileBytes,
              filename: image.path.split('/').last);
          formData.files.add(MapEntry("imageFiles", multipartFile));
        }
      }

      // API 호출
      Response response = await apiService.put('/api/diary', data: formData);

      if (response.statusCode == 200) {
        Navigator.of(context).pop({
          'action': 'update',
          'diaryIndex': widget.diaryIndex,
          'diaryTitle': title,
          'diaryContent': content,
          'selectedDay': selectedDay,
        });
      } else {
        print('Failed to update diary. Status code: ${response.statusCode}');
        print('Error response: ${response.data}');
        _showErrorDialog(
            'Failed to update diary. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioError) {
        print('Error updating diary: ${e.response?.data}');
        _showErrorDialog('Error updating diary: ${e.response?.data}');
      } else {
        print('Error updating diary: $e');
        _showErrorDialog('Error updating diary: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null && picked != selectedDay) {
      setState(() {
        selectedDay = picked.isAfter(DateTime.now()) ? DateTime.now() : picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();

    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.close_sharp,
                                    color: Colors.grey),
                                onPressed: () => Navigator.of(context).pop(),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${selectedDay.year}.${selectedDay.month.toString().padLeft(2, '0')}.${selectedDay.day.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _pickImages,
                          child: const Text('이미지 선택'),
                        ),
                        if (_selectedImages.isNotEmpty)
                          Column(
                            children: _selectedImages
                                .map((image) => Image.file(image))
                                .toList(),
                          ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9D1DD),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomPaint(
                              painter: LinedPaperPainter(),
                              foregroundPainter: NotebookHolesPainter(24),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 100,
                                ),
                                child: Scrollbar(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(30),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        TextField(
                                          controller: titleController,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '제목을 입력하세요',
                                            hintStyle: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextField(
                                          controller: contentController,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '내용을 입력하세요',
                                            hintStyle: TextStyle(
                                              fontSize: 18,
                                              color: Color(0xFFA488AF),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          maxLines: null,
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
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50),
                          child: ElevatedButton(
                            onPressed: updateDiary,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColors.color1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              '완료',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
    );
  }
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
    double xOffset = 20;

    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawCircle(Offset(xOffset, y), holeRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LinedPaperPainter extends CustomPainter {
  final double lineSpacing = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5;

    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
