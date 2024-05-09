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
  ApiService apiService =ApiService();

  void _toggleConfirmationView() {
    setState(() {
      showConfirmationView = !showConfirmationView;
    });
  }

  Future<void> sendContent() async {
    try {
      // Response response = await dio.get('https://k10b205.p.ssafy.io/api/analyze'); 
          //이렇게 쓰면 안됨..
      // 성공적으로 데이터를 받아오면 AnalysisPage로 이동
      Response response = await apiService.get('/api/analyze');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AnalysisPage(),
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

  //   try {
  //     // Response response = await apiService.get('/api/openAI/image?diaryIndex=${widget.diaryEntry.diaryIndex}');
  //     Response response = await apiService.get(
  //       '/api/openAI/image?diaryIndex=${widget.diaryIndex}',
  //     );
  //     print(response.data);

  //     setState(() {
  //       imageUrl = response.data['url'];
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //     print('Error generating image: $e');
  //   }
  // }

//   try {
//     final url = '/api/openAI/image?diaryIndex=${widget.diaryIndex}';
//     print('Request URL: $url'); // 디버깅용 출력
//     Response response = await apiService.get(url);

//     // 응답 데이터가 바로 이미지 URL이므로 문자열로 처리
//     setState(() {
//       imageUrl = response.data as String; // 응답 데이터를 바로 URL로 캐스팅
//       isLoading = false;
//     });
//   } catch (e) {
//     if (mounted) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//     print('Error generating image: $e');

//     // 추가적인 디버깅 정보 출력
//     if (e is DioException) {
//       print('DioException [${e.type}] - ${e.response?.statusCode}: ${e.response?.data}');
//       print('Request Headers: ${e.requestOptions.headers}');
//       print('Request Data: ${e.requestOptions.data}');
//     }
//   }
// }
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
      print('DioException [${e.type}] - ${e.response?.statusCode}: ${e.response?.data}');
      print('Request Headers: ${e.requestOptions.headers}');
      print('Request Data: ${e.requestOptions.data}');
    }
  }
}

//일기하나조회
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


    // 응답 데이터에서 `imageList` 배열 내의 첫 번째 `imageLink`를 추출
    if (response.data != null && response.data['imageList'] is List && response.data['imageList'].isNotEmpty) {
      final imageLink = response.data['imageList'][0]['imageLink'];
      print('Fetched imageLink: $imageLink');
      setState(() {
        imageUrl = imageLink;
        isLoading = false;
      });
    } else {
      print('No images found');
      setState(() {
        imageUrl = '';
        isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    print('Error fetching diary entry: $e');

    // 추가적인 디버깅 정보 출력
    if (e is DioException) {
      print('DioException [${e.type}] - ${e.response?.statusCode}: ${e.response?.data}');
      print('Request Headers: ${e.requestOptions.headers}');
      print('Request Data: ${e.requestOptions.data}');
    }
  }
}
//  Future<void> fetchDiaryEntry() async {
//     final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
//     await diaryProvider.fetchDiaryEntry(widget.diaryIndex);

//     // 일기 데이터 로드 후 이미지 URL 추출
//     final diaryEntry = diaryProvider.selectedDiaryEntry;
//     if (diaryEntry != null && diaryEntry.imageList.isNotEmpty) {
//       setState(() {
//         imageUrl = diaryEntry.imageList[0].imageLink;
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         imageUrl = '';
//         isLoading = false;
//       });
//     }
//   }

  @override
  void initState() {
    super.initState();
    fetchDiaryEntry();
  }


  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors(); // 테마 색상 인스턴스
    double modalWidth =
        MediaQuery.of(context).size.width * 0.8; // modalWidth를 여기에서 정의
    // double contentWidth = modalWidth - 60; // 실제 컨텐츠 영역의 넓이 계산
    // double contentWidth  = modalWidth - 32; // 16px 마진을 양쪽에서 빼줍니다

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
                  padding: const EdgeInsets.all(16.0), // 내부 여백 추가
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
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_left_rounded),
                            onPressed: () {
                              // 이전 일기 로드
                            },
                            iconSize: 30,
                          ),
                          Text(
                            '${widget.selectedDay.year}.${widget.selectedDay.month.toString().padLeft(2, '0')}.${widget.selectedDay.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 22),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.keyboard_arrow_right_rounded),
                            onPressed: () {
                              // 다음 일기 로드
                            },
                            iconSize: 30,
                          ),
                        ],
                      ),
                     Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.start, // 버튼들을 왼쪽 정렬
                          children: [
                            const SizedBox(width: 15), // 추가적인 왼쪽 공간
                            // 새로운 AI 이미지 생성 아이콘 버튼 추가
                            IconButton(
                              // icon: Image.asset('assets/icons/ai-file.png', width: 5, height: 5), // 이미지 파일 사용
                              icon: const Icon(Icons.brush), // 예시 아이콘, 적절한 아이콘으로 교체 필요
                              // icon: const Icon(Icons.palette),
                              // icon: const Icon(Icons.photo_filter_rounded),
// icon: const Icon(Icons.add_photo_alternate),

                              color: themeColors.color1, // 아이콘 색상 지정
                              onPressed: generateImage, // AI 이미지 생성 로직 연결
                            ),
                            
                            const SizedBox(width: 140), // AI 버튼과 삭제 버튼 간의 간격

                            // 기존 '삭제' 버튼
                            ElevatedButton(
                              onPressed: () {
                                // 일기 삭제
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColors.color2, // 배경색
                                foregroundColor: Colors.white, // 텍스트색
                                minimumSize: const Size(50, 25), // 최소 크기 지정
                                padding: EdgeInsets.zero, // 최소 패딩
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(45), // 모서리 둥글게
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '삭제',
                                  style: TextStyle(fontSize: 16), // 폰트사이즈 설정
                                ),
                              ),
                            ),
                            const SizedBox(width: 10), // 버튼 간 간격 조정
                            // 기존 '수정' 버튼
                            ElevatedButton(
                              onPressed: _toggleConfirmationView,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColors.color1, // 배경색
                                minimumSize: const Size(50, 25), // 최소 크기 지정
                                foregroundColor: Colors.white, // 텍스트색
                                padding: EdgeInsets.zero, // 최소 패딩
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(45), // 모서리 둥글게
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '수정',
                                  style: TextStyle(fontSize: 16), // 폰트사이즈 설정
                                ),
                              ),
                            ),
                            const SizedBox(width: 20), // 추가적인 오른쪽 공간
                          ],
                        ),
                      ),
                      // 이미지 생성
                      const SizedBox(height: 15),
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (imageUrl.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Image.network(
                            imageUrl,
                            errorBuilder: (context, error, stackTrace) {
                              print('Image loading error: $error');
                              return const Text('이미지 로딩 실패');
                            },
                          ),
                        )
                      else
                        const SizedBox(),


                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFFF9D1DD), // Pink background color
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                          ),
                          child: CustomPaint(
                            painter: LinedPaperPainter(),
                            foregroundPainter: NotebookHolesPainter(
                                24), // Line spacing for notebook holes
                            child: SizedBox(
                              width: modalWidth,
                              height: 400, // Fixed height
                              child: Padding(
                                padding: const EdgeInsets.all(30),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 50),
                        child: ElevatedButton(
                          onPressed: sendContent,
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
    double xOffset = 20; // 구멍의 x축 위치

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
