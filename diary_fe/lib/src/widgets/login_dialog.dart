import 'dart:async';

import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/error/social_login_error.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/screens/pages.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:diary_fe/src/widgets/signup_dialog.dart';
import 'package:diary_fe/src/widgets/textform.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class LoginModal extends StatefulWidget {
  const LoginModal({super.key});

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String platform = '';
  ApiService apiService = ApiService();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _isButtonEnabled = true;
  final storage = const FlutterSecureStorage();

  final formKey = GlobalKey<FormState>();

  Future<void> measureAsyncFunctionPerformance(int count) async {
    List<int> executionTimes = [];
    int minTime = 1000000;
    int maxTime = 0;

    // 모든 비동기 작업을 저장할 리스트
    List<Future<void>> allTasks = [];

    // 현재 시간을 기준으로 모든 비동기 작업을 시작
    for (int i = 0; i < count; i++) {
      var index = i + 1; // 요청 인덱스
      var startTime = DateTime.now(); // 시작 시간

      // 비동기 작업 실행
      allTasks.add(sendTextToAPI("이건 $i 번째 요청인데 좀 잘 답해주세요.").then((result) {
        var endTime = DateTime.now();
        int duration = endTime.difference(startTime).inMilliseconds;
        executionTimes.add(duration);

        // 결과와 실행 시간 출력
        print("Execution $index: $result, Time: ${duration}ms");

        // 최소 및 최대 실행 시간 업데이트
        if (duration < minTime) minTime = duration;
        if (duration > maxTime) maxTime = duration;
      }));
    }

    // 모든 비동기 작업이 완료될 때까지 기다림
    await Future.wait(allTasks);

    // 전체 실행에서의 최소 및 최대 실행 시간 출력
    print("\nFastest execution time: ${minTime}ms");
    print("Slowest execution time: ${maxTime}ms");
  }

  Future<String> sendTextToAPI(String text) async {
    // 여기에 API 요청 로직을 구현하세요.

    ApiService apiService = ApiService();
    Response response = await apiService.get('/api/ai/chatbot?input=$text');
    print(response.data);
    return response.data;
  }

  Future<void> measureAsyncFunction(
      Future<void> Function() asyncFunction, int iterations) async {
    if (iterations < 100) {
      throw ArgumentError('iterations must be at least 100');
    }

    List<int> executionTimes = [];

    for (int i = 0; i < iterations; i++) {
      Stopwatch stopwatch = Stopwatch()..start();
      await asyncFunction();
      stopwatch.stop();
      executionTimes.add(stopwatch.elapsedMicroseconds);
      print('함수결과$i, 실행시간: ${stopwatch.elapsedMicroseconds} 마이크로초');
    }

    executionTimes.sort();
    int fastestTime = executionTimes.first;
    int slowestTime = executionTimes.last;

    print('가장 빠른 요청 시간: $fastestTime 마이크로초');
    print('가장 느린 요청 시간: $slowestTime 마이크로초');
  }

  Future<void> login() async {
    if (_idController.text.isEmpty || _pwController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: const Text('아이디와 비밀번호를 모두 입력해야 해요.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
      return;
    }
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .login(_idController.text, _pwController.text);
      await Provider.of<UserProvider>(context, listen: false).fetchUserData();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Pages(),
          ));
    } catch (e) {
      if (e is DioException) {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // 다이얼로그 바깥을 터치해도 닫히지 않도록 설정
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('로그인 오류'),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('회원가입이 되어있지 않거나, 아이디나 \n비밀번호가 달라요.'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _handleButtonClick() {
    setState(() {
      _isButtonEnabled = false; // 버튼 비활성화
    });
    login();

    // 2초 후에 버튼을 다시 활성화
    Future.delayed(const Duration(microseconds: 500), () {
      setState(() {
        _isButtonEnabled = true; // 버튼 활성화
      });
    });
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 바깥을 터치해도 닫히지 않도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('에러 발생'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> showEmailRequest(BuildContext context) async {
    TextEditingController emailController = TextEditingController();
    TextEditingController verificationCodeController = TextEditingController();
    Timer? timer;
    bool isVerified = false;
    String? errorText = '';
    bool isCodeSent = false;
    String verificationId = '';
    int remainingTime = 300;
    String? inputText = '';
    bool isButtonDisabled = false; // 버튼 활성화 상태 관리
    String? verifiedEmail;
    StateSetter? _setState;

    bool isEmailValid(String email) {
      final RegExp emailRegExp = RegExp(
        r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
      );
      if (emailRegExp.hasMatch(email)) {
        errorText = '';
      }
      return emailRegExp.hasMatch(email);
    }

    void startTimer() {
      _setState!(() {
        remainingTime = 300; // 초 단위, 5분
        isButtonDisabled = true;
      });
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingTime > 0) {
          _setState!(() => remainingTime--);
          print(remainingTime);
        } else {
          timer.cancel();
          _setState!(() {
            isButtonDisabled = false;
            isCodeSent = false;
          });
          const Text('시간이 초과되었습니다.');
        }
      });
    }

    Future<bool> verifyEmail(String email) async {
      try {
        ApiService apiService = ApiService();
        Response response = await apiService.post(
          '/api/email/verification',
          data: {
            "email": email,
          },
        );

        if (response.statusCode == 200) {
          timer?.cancel();
          print("도착");
          _setState!(() {
            verificationId = response.data["verificationId"];
          });
          return true;
          // 인증 코드 발송 성공 메시지 또는 로직
        } else {
          return false;
          // 인증 코드 발송 실패 처리
        }
      } catch (e) {
        if (e is DioException) {
          if (e.response?.statusCode == 400 &&
              e.response?.data == 'request Too many') {}
          switch (e.response?.statusCode) {
            case 409:
              errorText = "이미 존재하는 이메일 입니다";
              return false;
              break;
            case 400:
              switch (e.response?.data) {
                case 'request Too many':
                  showErrorDialog(context as BuildContext,
                      '이메일을 너무 자주 전송하고 있어요. 조금 기다렸다 시도해보세요.');
                  return false;
                  break;
                default:
                  return false;
              }
          }
          return false;
        }
        return false;
      }
    }

    Future<bool> confirmVerification(String code) async {
      // 인증 코드 확인 로직
      try {
        ApiService apiService = ApiService();
        Response response = await apiService.post(
          '/api/email/auth',
          data: {"verificationId": verificationId, "code": code},
        );
        if (response.statusCode == 200) {
          timer?.cancel();

          return true;
        }
        return false;
      } catch (e) {
        if (e is DioException) {
          showDialog<void>(
            context: context,
            barrierDismissible: false, // 다이얼로그 바깥을 터치해도 닫히지 않도록 설정
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('에러 발생'),
                content: const SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('인증코드가 일치하지 않아요. 확인하고 다시 입력해보세요.'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('확인'),
                    onPressed: () {
                      Navigator.pop(context); // 다이얼로그 닫기
                    },
                  ),
                ],
              );
            },
          );
        }
        return false;
      }
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("이메일 인증"),
          content: StatefulBuilder(builder: (context, StateSetter setState) {
            _setState = setState;
            return Form(
                key: formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      hintText: 'your_email@example.com',
                    ),
                    validator: (value) {
                      return emailController.text.isEmpty
                          ? "이메일을 입력해야합니다."
                          : isEmailValid(value!)
                              ? null
                              : '유효한 이메일을 입력해주세요.';
                    },
                    onSaved: (value) {
                      if (emailController.text.isNotEmpty &&
                          isEmailValid(emailController.text)) {
                        setState(() {
                          inputText = value!;
                        });
                      }
                    },
                  ),
                  if (isCodeSent) ...<Widget>[
                    Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: TextForm(
                                title: '이메일 인증 코드',
                                controller: verificationCodeController,
                                suffix: IconButton(
                                  onPressed: () async {
                                    bool confirm = await confirmVerification(
                                        verificationCodeController.text);
                                    if (confirm) {
                                      setState(() {
                                        isVerified = true;
                                        verifiedEmail = inputText;
                                      });
                                    }
                                  },
                                  icon: Text(
                                    '확인',
                                    style: TextStyle(color: ThemeColors.color1),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 2,
                              child: isVerified
                                  ? const Text(
                                      '인증 성공',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    )
                                  : Text(
                                      "${(remainingTime / 60).floor().toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                  TextButton(
                    onPressed: isButtonDisabled
                        ? null
                        : isVerified
                            ? () {
                                Navigator.pop(context, verifiedEmail);
                              }
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();
                                  bool requestSent =
                                      await verifyEmail(inputText!);
                                  if (requestSent) {
                                    setState(() {
                                      startTimer();
                                      isButtonDisabled = false;
                                      isCodeSent = true;
                                    });
                                  }
                                }
                              },
                    child: !isButtonDisabled && isVerified
                        ? const Text("계속 진행")
                        : const Text('인증 요청'),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("취소")
                  ),
                ]));
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          backgroundColor: const Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SizedBox(
            width: 380,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 모달 컨텐츠 크기에 맞게 조절
                children: <Widget>[
                  Text(
                    '로그인',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: ThemeColors.color1),
                  ),
                  const SizedBox(height: 25), // 간격 추가
                  TextForm(title: '아이디', controller: _idController),
                  const SizedBox(height: 20), // 간격 추가
                  TextForm(title: '비밀번호', controller: _pwController),

                  const SizedBox(height: 30), // 간격 추가
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled ? _handleButtonClick : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.color1, // 버튼 색상
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '로그인',
                        style: TextStyle(
                          color: ThemeColors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // 간격 추가
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '아직 계정이 없으신가요?',
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeColors.color1,
                            fontWeight: FontWeight.w600,
                            // 밑줄
                          ),
                        ),
                        SizedBox(
                          width: 1,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    dialogBackgroundColor:
                                        const Color(0xFFFFFFFF),
                                    dialogTheme:
                                        const DialogTheme(elevation: 0),
                                  ),
                                  child: const SignUpModal(),
                                );
                              },
                            );
                          },
                          child: Text(
                            '여기를 클릭하세요!',
                            style: TextStyle(
                              fontSize: 13,
                              color: ThemeColors.color2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                              right: 10.0), // 텍스트와의 간격을 주기 위해 마진 설정
                          child: Divider(
                            color: ThemeColors.color1, // 선의 색상
                            height: 1.5, // Divider의 높이를 설정
                          ),
                        ),
                      ),
                      Text(
                        "간편로그인",
                        style: TextStyle(
                          color: ThemeColors.color1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 10.0), // 텍스트와의 간격을 주기 위해 마진 설정
                          child: Divider(
                            color: ThemeColors.color1, // 선의 색상

                            height: 1.5, // Divider의 높이를 설정
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    child: Ink.image(
                      image: const AssetImage('assets/images/kakao.png'),
                      fit: BoxFit.cover, // 이미지 채우기 방식 지정
                      width: 200,
                      height: 40,
                      child: InkWell(
                        onTap: () async {
                          try {
                            await Provider.of<UserProvider>(context,
                                    listen: false)
                                .kakaoLogin();
                          } catch (e) {
                            if (e is SocialLoginError) {
                              switch (e.message.toString()) {
                                case "Email Required":
                                  String? email =
                                      await showEmailRequest(context);
                                  if (email==null||email!.isEmpty || email == '') {
                                    await Provider.of<UserProvider>(context,
                                            listen: false).unLink();
                                    showErrorDialog(context as BuildContext, '가입을 취소 했습니다.');
                                    return;
                                  }
                                  await Provider.of<UserProvider>(context,
                                          listen: false)
                                      .retryKakaoLogin(email);
                                  break;
                                default:
                              }
                            }
                          }
                          await Provider.of<UserProvider>(context,
                                  listen: false).fetchUserData();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Pages(),
                            ),
                          );
                        },

                        // InkWell이 꽉 찬 영역에 반응하도록 Container 등으로 감싸거나 크기를 지정
                        child: const SizedBox(
                          width: 500, // InkWell의 크기를 지정
                          height: 60,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      // await measureAsyncFunction(() => _sendTextToAPI("응답해주세요 이건 메시지입니다."), 200);
                      measureAsyncFunctionPerformance(100);
                    },
                    child: Text(
                      '부하 테스트!',
                      style: TextStyle(
                        fontSize: 13,
                        color: ThemeColors.gray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
