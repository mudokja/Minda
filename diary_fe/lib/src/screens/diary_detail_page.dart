import 'package:diary_fe/src/screens/pages.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';
import 'package:diary_fe/src/services/diary_provider.dart';
import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/widgets/background.dart'; // Background 위젯 import
import 'package:intl/intl.dart';
import 'package:diary_fe/src/screens/analysis_page.dart';
import 'package:diary_fe/src/models/diary_image.dart';

class DiaryDetailPage extends StatefulWidget {
  final DateTime selectedDay;
  final String diaryTitle;
  final String diaryContent;
  final int diaryIndex; // diaryIndex필드 추가

  const DiaryDetailPage({
    super.key,
    required this.selectedDay,
    required this.diaryTitle,
    required this.diaryContent,
    required this.diaryIndex, //diaryIndex 필드 추가
  });

  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  Dio dio = Dio(); // Dio 인스턴스 생성
  bool showConfirmationView = false; // 상태를 관리하는 변수
  bool isLoading = false; //로딩 상태 관리
  String imageUrl = ''; // 생성된 이미지 URL 저장
  ApiService apiService = ApiService();

  // 여기에 추가
  String diaryDate = '';
  String diaryTitle = '';
  String diaryContent = '';

  // 컨트롤러 선언
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDiaryEntry();
  }

  void _toggleConfirmationView() {
    setState(() {
      showConfirmationView = !showConfirmationView;
    });
  }

  // 일기 하나 조회
  Future<void> fetchDiaryEntry() async {
    print('Fetching diary entry with index: ${widget.diaryIndex}');
    setState(() {
      isLoading = true;
      // imageUrl = ''; // 이전 이미지를 초기화
    });

    try {
      final url = '/api/diary?diaryIndex=${widget.diaryIndex}';
      print('Request URL: $url');
      Response response = await apiService.get(url);

      // 전체 데이터 출력
      print('Response Data: ${response.data}');

      if (response.data != null) {
        final data = response.data;
        final imageList = data['imageList'] as List;
        if (imageList.isNotEmpty) {
          final imageLink = imageList[0]['imageLink'];
          setState(() {
            imageUrl = imageLink;
          });
        }
        // 날짜, 제목, 내용도 상태 변수에 저장
        setState(() {
          diaryDate = data['diarySetDate']; // 날짜 형식에 맞게 조정해야 할 수 있음
          diaryTitle = data['diaryTitle'];
          diaryContent = data['diaryContent'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching diary entry: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendContent() async {
    try {
      // Response response = await dio.get('https://k10b205.p.ssafy.io/api/analyze');
      //이렇게 쓰면 안됨..
      // 성공적으로 데이터를 받아오면 AnalysisPage로 이동
      // Response response = await apiService.get('/api/analyze');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Pages(
            initialPage: 2,
            selectedDate: DateTime.parse(diaryDate),
          ),
        ),
      );
    } catch (e) {
      // 요청 실패 처리
      print('Error fetching analysis: $e');
    }
  }

  Future<void> generateImage() async {
    // ApiService apiService =ApiService();
    print('diaryIndex: ${widget.diaryIndex}'); // 디버깅용 출력
    setState(() {
      isLoading = true;
      imageUrl = ''; // 이전 이미지를 초기화
    });

    try {
      final url = '/api/openAI/image?diaryIndex=${widget.diaryIndex}';
      print('Request URL: $url'); // 디버깅용 출력
      Response response = await apiService.get(url);

      // 응답 데이터가 올바른 URL인지 확인
      if (response.data is String && response.data.isNotEmpty) {
        setState(() {
          imageUrl = response.data;
          isLoading = false;
        });
      } else {
        print('Invalid image URL');
        setState(() {
          isLoading = false;
          imageUrl = ''; // 오류 시 빈 이미지 URL
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error generating image: $e');

      // 추가적인 디버깅 정보 출력
      if (e is DioException) {
        print(
            'DioException [${e.type}] - ${e.response?.statusCode}: ${e.response?.data}');
        print('Request Headers: ${e.requestOptions.headers}');
        print('Request Data: ${e.requestOptions.data}');
      }
    }
  }

  Future<void> updateDiary() async {
    try {
      const url = '/api/diary';
      final data = {
        'diaryIndex': widget.diaryIndex,
        'diarySetDate': diaryDate,
        'diaryTitle': titleController.text,
        'diaryContent': contentController.text,
      };
      Response response = await apiService.put(url, data: data);

      if (response.statusCode == 200) {
        print('Diary updated successfully');
        setState(() {
          diaryTitle = titleController.text;
          diaryContent = contentController.text;
          showConfirmationView = false;
        });
        Navigator.of(context).pop({
          'action': 'update',
          'diaryIndex': widget.diaryIndex,
          'diaryTitle': diaryTitle,
          'diaryContent': diaryContent,
        });
      } else {
        print('Failed to update diary');
      }
    } catch (e) {
      print('Error updating diary: $e');
    }
  }

  Future<void> deleteDiary() async {
    try {
      final url = '/api/diary?diaryIndex=${widget.diaryIndex}';
      Response response = await apiService.delete(url);

      if (response.statusCode == 200) {
        print('Diary deleted successfully');
        // Navigator.of(context).pop(); // 페이지를 닫고 이전 페이지로 돌아감
        Navigator.of(context).pop({
          'action': 'delete',
          'diaryIndex': widget.diaryIndex,
        });
      } else {
        print('Failed to delete diary');
      }
    } catch (e) {
      print('Error deleting diary: $e');
    }
  }

  void onPreviousButtonPressed() {
    DateTime startDate = widget.selectedDay.subtract(const Duration(days: 30));
    DateTime endDate = widget.selectedDay.add(const Duration(days: 30));
    navigateToDiary(startDate, endDate, false);
  }
   void onNextButtonPressed() {
    DateTime startDate = widget.selectedDay.subtract(const Duration(days: 30));
    DateTime endDate = widget.selectedDay.add(const Duration(days: 30));
    navigateToDiary(startDate, endDate, true);
  }

  Future<void> navigateToDiary(DateTime startDate, DateTime endDate, bool next) async {
  try {
    List<DiaryEntry> diaries = await fetchDiaries(startDate, endDate);
    DiaryEntry? closestDiary = findClosestDiary(diaries, widget.selectedDay, next);
    if (closestDiary != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => DiaryDetailPage(
            selectedDay: DateTime.parse(closestDiary.diarySetDate),
            diaryTitle: closestDiary.diaryTitle,
            diaryContent: closestDiary.diaryContent,
            diaryIndex: closestDiary.diaryIndex,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = next ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // 널 처리 로직 추가: 사용자에게 적절한 메시지 표시 등
      print("No diary entry found close to the selected date.");
    }
  } catch (error) {
    print('Error navigating to diary entry: $error');
  }
}


  Future<List<DiaryEntry>> fetchDiaries(DateTime startDate, DateTime endDate) async {
    final response = await apiService.post('/api/diary/list/period', data: {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
    });

    if (response.statusCode == 200) {
      return (response.data as List).map((item) => DiaryEntry.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load diaries');
    }
  }

DiaryEntry? findClosestDiary(List<DiaryEntry> diaries, DateTime targetDate, bool next) {
    DiaryEntry? closestDiary;
    int closestDiff  = 10000; // 예를 들어 최대 10000일 차이로 설정, 이는 상황에 따라 조절할 수 있습니다.
    
    for (var diary in diaries) {
        DateTime diaryDate = DateTime.parse(diary.diarySetDate);
        int diff = diaryDate.difference(targetDate).inDays.abs();
        
        if (next && diaryDate.isAfter(targetDate) && (closestDiary == null || diff < closestDiff)) {
            closestDiary = diary;
            closestDiff = diff;
        } else if (!next && diaryDate.isBefore(targetDate) && (closestDiary == null || diff < closestDiff)) {
            closestDiary = diary;
            closestDiff = diff;
        }
    }
    return closestDiary;
}

  // @override
  // Widget build(BuildContext context) {
  //   ThemeColors themeColors = ThemeColors(); // 테마 색상 인스턴스
  //   double modalWidth =
  //       MediaQuery.of(context).size.width * 0.8; // modalWidth를 여기에서 정의
  //   // double contentWidth = modalWidth - 60; // 실제 컨텐츠 영역의 넓이 계산
  //   // double contentWidth  = modalWidth - 32; // 16px 마진을 양쪽에서 빼줍니다

//     return Scaffold(
//       body: Stack(
//         children: [
//           const Background(), // 배경 위젯
//           Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxHeight: MediaQuery.of(context).size.height * 0.9, // 최대 높이 설정
//               ),
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.9, // 화면의 90% 크기
//                 decoration: BoxDecoration(
//                   color: Colors.white, // 컨테이너의 배경색
//                   borderRadius: BorderRadius.circular(35), // 모서리 둥글게
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       spreadRadius: 1,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3), // 그림자 위치 조정
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   // padding: const EdgeInsets.all(16.0), // 내부 여백 추가
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch, // 가로로 꽉 차게
//                     children: [
//                       Stack(
//                         children: [
//                           // Position the close button on the right
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: IconButton(
//                               icon: const Icon(Icons.close_sharp,
//                                   color: Colors
//                                       .grey), // Icon color changed to grey
//                               onPressed: () => Navigator.of(context).pop(),
//                               padding: EdgeInsets.zero, // 간격 최소화
//                             ),
//                           ),
//                         ],
//                       ),

//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.keyboard_arrow_left_rounded),
//                             // 이전 일기 로드
//                               onPressed: onPreviousButtonPressed,
                      
//                               iconSize: 30,
//                               padding: EdgeInsets.zero, // 간격 최소화
//                             ),
//                             Text(
//                               '${widget.selectedDay.year}.${widget.selectedDay.month.toString().padLeft(2, '0')}.${widget.selectedDay.day.toString().padLeft(2, '0')}',
//                               style: const TextStyle(fontSize: 22),
//                             ),
//                             IconButton(
//                               icon:
//                                   const Icon(Icons.keyboard_arrow_right_rounded),
//                                   // 다음 일기 로드
//                               onPressed: onNextButtonPressed,
//                               iconSize: 30,
//                               padding: EdgeInsets.zero, // 간격 최소화
//                             ),
//                           ],
//                         ),

//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.brush),
//                               color: themeColors.color1,
//                               onPressed:
//                                   imageUrl.isEmpty ? generateImage : null,
//                               padding: EdgeInsets.zero, // 간격 최소화
//                             ),
//                             if (!isLoading && imageUrl.isEmpty)
//                               const Text(
//                                 'AI로 이미지를\n생성해보세요!',
//                                 style: TextStyle(fontSize: 12),
//                               ),
//                             const SizedBox(width: 90),
//                             Row(
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: deleteDiary,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: themeColors.color2,
//                                     foregroundColor: Colors.white,
//                                     minimumSize: const Size(50, 25),
//                                     padding: EdgeInsets.zero,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(45),
//                                     ),
//                                   ),
//                                   child: const Center(
//                                     child: Text(
//                                       '삭제',
//                                       style: TextStyle(fontSize: 16),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 ElevatedButton(
//                                   onPressed: _toggleConfirmationView,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: themeColors.color1,
//                                     minimumSize: const Size(50, 25),
//                                     foregroundColor: Colors.white,
//                                     padding: EdgeInsets.zero,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(45),
//                                     ),
//                                   ),
//                                   child: const Center(
//                                     child: Text(
//                                       '수정',
//                                       style: TextStyle(fontSize: 16),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       // const SizedBox(height: 15),
//                       if (isLoading)
//                         Container(
//                           width: double.infinity,
//                           height: MediaQuery.of(context).size.height * 0.3,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade200,
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                               color: themeColors.color2, // 테두리 색상
//                               width: 2, // 테두리 두께
//                             ),
//                           ),
//                           margin: const EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 10),
//                           child: const Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               CircularProgressIndicator(),
//                               SizedBox(height: 10),
//                               Text(
//                                 '이미지를 생성중입니다.',
//                                 style: TextStyle(fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         )
//                       else if (imageUrl.isNotEmpty)
//                         Container(
//                           width: double.infinity,
//                           height: MediaQuery.of(context).size.height * 0.3,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade200,
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                               color: themeColors.color2, // 테두리 색상
//                               width: 2, // 테두리 두께
//                             ),
//                           ),
//                           margin: const EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 10),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Image.network(
//                               imageUrl,
//                               fit: BoxFit.contain,
//                               errorBuilder: (context, error, stackTrace) {
//                                 print('Image loading error: $error');
//                                 return const Text('이미지 로딩 실패');
//                               },
//                             ),
//                           ),
//                         )
//                       else
//                         const SizedBox(),

//                           // 여기를 SingleChildScrollView로 감싸줍니다
//                       // Expanded(
//                         // child: 
//                         SingleChildScrollView(
//                           child: Column(
//                             children: [
//                               Container(
//                                 // margin: const EdgeInsets.all(16),
//                                 margin: const EdgeInsets.fromLTRB(16, 5, 16, 10),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFF9D1DD),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: CustomPaint(
//                                   painter: LinedPaperPainter(),
//                                   foregroundPainter: NotebookHolesPainter(24),
//                                   child: SizedBox(
//                                     width: modalWidth,
//                                     height: 400,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(30),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: <Widget>[
//                                           Text(
//                                             widget.diaryTitle.isNotEmpty
//                                                 ? widget.diaryTitle
//                                                 : '${widget.selectedDay.year}년 ${widget.selectedDay.month}월 ${widget.selectedDay.day}일의 일기',
//                                             style: const TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                           const SizedBox(height: 20),
//                                           Text(
//                                             widget.diaryContent.isNotEmpty
//                                                 ? widget.diaryContent
//                                                 : '일기가 작성되지 않았어요..',
//                                             style: const TextStyle(
//                                                 fontSize: 18,
//                                                 color: Color(0xFFA488AF),
//                                                 fontWeight: FontWeight.w600),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Container(
//                                 margin: const EdgeInsets.symmetric(horizontal: 50),
//                                 child: ElevatedButton(
//                                   onPressed: sendContent,
//                                   // onPressed: null, // 버튼 비활성화
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: themeColors.color1,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     '일기 분석 보기',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w600),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



                      

// class NotebookHolesPainter extends CustomPainter {
//   final double lineSpacing;

//   NotebookHolesPainter(this.lineSpacing);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;

//     double holeRadius = 5;
//     double xOffset = 20;

//     for (double y = lineSpacing; y < size.height; y += lineSpacing) {
//       canvas.drawCircle(Offset(xOffset, y), holeRadius, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class LinedPaperPainter extends CustomPainter {
//   final double lineSpacing = 24;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.grey.shade300
//       ..strokeWidth = 1.5;

//     for (double y = lineSpacing; y < size.height; y += lineSpacing) {
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }

 @override
Widget build(BuildContext context) {
  ThemeColors themeColors = ThemeColors(); // 테마 색상 인스턴스
  double modalWidth =
      MediaQuery.of(context).size.width * 0.9; // modalWidth를 여기에서 정의

  return Scaffold(
    body: Stack(
      children: [
        const Background(), // 배경 위젯
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9, // 최대 높이 설정
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, // 화면의 90% 크기
              decoration: BoxDecoration(
                color: Colors.white, // 컨테이너의 배경색
                borderRadius: BorderRadius.circular(35), // 모서리 둥글게
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // 그림자 위치 조정
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SingleChildScrollView( // 여기를 SingleChildScrollView로 감싸줍니다
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // 가로로 꽉 차게
                    children: [
                      Stack(
                        children: [
                          // Position the close button on the right
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.close_sharp,
                                  color: Colors
                                      .grey), // Icon color changed to grey
                              onPressed: () => Navigator.of(context).pop(),
                              padding: EdgeInsets.zero, // 간격 최소화
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_left_rounded),
                            onPressed: onPreviousButtonPressed, // 이전 일기 로드
                            iconSize: 30,
                            padding: EdgeInsets.zero, // 간격 최소화
                          ),
                          Text(
                            '${widget.selectedDay.year}.${widget.selectedDay.month.toString().padLeft(2, '0')}.${widget.selectedDay.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 22),
                          ),
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_right_rounded),
                            onPressed: onNextButtonPressed, // 다음 일기 로드
                            iconSize: 30,
                            padding: EdgeInsets.zero, // 간격 최소화
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.brush),
                              color: themeColors.color1,
                              onPressed: imageUrl.isEmpty ? generateImage : null,
                              padding: EdgeInsets.zero, // 간격 최소화
                            ),
                            if (!isLoading && imageUrl.isEmpty)
                              const Text(
                                'AI로 이미지를\n생성해보세요!',
                                style: TextStyle(fontSize: 12),
                              ),
                            const SizedBox(width: 90),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: deleteDiary,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeColors.color2,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(50, 25),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(45),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '삭제',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _toggleConfirmationView,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeColors.color1,
                                    minimumSize: const Size(50, 25),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(45),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '수정',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isLoading)
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: themeColors.color2, // 테두리 색상
                              width: 2, // 테두리 두께
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 10),
                              Text(
                                '이미지를 생성중입니다.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      else if (imageUrl.isNotEmpty)
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: themeColors.color2, // 테두리 색상
                              width: 2, // 테두리 두께
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print('Image loading error: $error');
                                return const Text('이미지 로딩 실패');
                              },
                            ),
                          ),
                        )
                      else
                        const SizedBox(),
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 5, 16, 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9D1DD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomPaint(
                          painter: LinedPaperPainter(),
                          foregroundPainter: NotebookHolesPainter(24),
                          child: SizedBox(
                            width: modalWidth,
                            height: 400,
                            child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    widget.diaryTitle.isNotEmpty
                                        ? widget.diaryTitle
                                        : '${widget.selectedDay.year}년 ${widget.selectedDay.month}월 ${widget.selectedDay.day}일의 일기',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    widget.diaryContent.isNotEmpty
                                        ? widget.diaryContent
                                        : '일기가 작성되지 않았어요..',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFFA488AF),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 50),
                        child: ElevatedButton(
                          onPressed: sendContent,
                          // onPressed: null, // 버튼 비활성화
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColors.color1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '일기 분석 보기',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
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

class NotebookHolesPainter extends CustomPainter { // 클래스 정의 추가
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

class LinedPaperPainter extends CustomPainter { // 클래스 정의 추가
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
 