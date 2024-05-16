import 'dart:async';
import 'package:diary_fe/constants.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:diary_fe/src/widgets/login_dialog.dart';
import 'package:diary_fe/src/widgets/signup_success.dart';
import 'package:diary_fe/src/widgets/textform.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';

class SignUpModal extends StatefulWidget {
  const SignUpModal({super.key});

  @override
  State<SignUpModal> createState() => _SignUpModalState();
}

class _SignUpModalState extends State<SignUpModal> {
  final storage = const FlutterSecureStorage();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pw2Controller = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  String _idError = '';
  String _emailError = '';
  String _pwError = '';
  String _pw2Error = '';
  String _nicknameError = '';
  bool _isVerified = false;
  bool _isButtonEnabled = true;

  Timer? _timer; // 타이머
  int _remainingTime = 300; // 초 단위, 5분
  bool _isCodeSent = false;
  String verificationId = '';
  String _idSuccessMessage = '';
  String _idErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _idController.addListener(_validateId);
    _emailController.addListener(_validateEmail);
    _pwController.addListener(_validatePassword);
    _pw2Controller.addListener(_validatePasswordConfirmation);
    _nicknameController.addListener(_validateNickname);
  }

  void _validateId() {
    final idText = _idController.text;
    if (RegExp(r'[\uac00-\ud7a3]').hasMatch(idText) ||
        RegExp(r'[\u3131-\u314E\u3165-\u3186\u314F-\u3163]+')
            .hasMatch(idText)) {
      // 한글 정규 표현식
      _setIdError('아이디에는 한글이 포함될 수 없습니다.');
    } else {
      _setIdError(null);
    }
  }

  void _validateEmail() {
    final emailText = _emailController.text;
    if (emailText.isEmpty) {
      _setEmailError(null);
    } else if (!EmailValidator.validate(emailText)) {
      _setEmailError('유효하지 않은 이메일 형식입니다.');
    } else {
      _setEmailError(null);
    }
  }

  void _setIdError(String? error) {
    setState(() {
      _idError = error ?? '';
    });
  }

  void _setEmailError(String? error) {
    setState(() {
      _emailError = error ?? '';
    });
  }

  void _validatePassword() {
    final password = _pwController.text;

    // 정규 표현식: 영문자와 숫자를 각각 하나 이상 포함해야 함
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

    if (password.isEmpty) {
      _setPasswordError(null);
    } else if (!passwordRegex.hasMatch(password)) {
      _setPasswordError('비밀번호는 최소 8자 이상이어야 하며,\n영문자와 숫자를 모두 포함해야 합니다.');
    } else {
      _setPasswordError(null);
    }
    // 비밀번호 확인도 다시 검사
    _validatePasswordConfirmation();
  }

  void _validatePasswordConfirmation() {
    final password = _pwController.text;
    final confirmation = _pw2Controller.text;
    if (confirmation.isEmpty) {
      _setPassword2Error(null);
    } else if (password != confirmation) {
      _setPassword2Error('비밀번호가 일치하지 않습니다.');
    } else {
      _setPassword2Error(null);
    }
  }

  void _setPasswordError(String? error) {
    setState(() {
      _pwError = error ?? '';
    });
  }

  void _setPassword2Error(String? error) {
    setState(() {
      _pw2Error = error ?? '';
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

  @override
  void dispose() {
    _idController.removeListener(_validateId);
    _idController.dispose();
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    _pwController.removeListener(_validatePassword);
    _pwController.dispose();
    _pw2Controller.removeListener(_validatePasswordConfirmation);
    _pw2Controller.dispose();
    _nicknameController.removeListener(_validateNickname);
    _nicknameController.dispose();
    super.dispose();
  }

  void emailDuplicate() async {
    try {
      ApiService apiService = ApiService();
      Response response = await apiService.get(
        '/api/member/check?email=${_emailController.text}',
      );
      if (response.statusCode == 200) {
        verifyEmail();
      }
    } catch (e) {
      if (e is DioException) {
        _setEmailError('중복된 이메일이에요. 다른 이메일로 시도해보세요.');
      }
    }
  }

  void verifyEmail() async {
    try {
      ApiService apiService = ApiService();

      Response response = await apiService.post(
        '/api/email/verification',
        data: {
          "email": _emailController.text,
        },
      );

      if (response.statusCode == 200) {
        _timer?.cancel();
        setState(() {
          _isCodeSent = true;
          verificationId = response.data["verificationId"];
          startTimer();
        });
        // 인증 코드 발송 성공 메시지 또는 로직
      } else {
        // 인증 코드 발송 실패 처리
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400 &&
            e.response?.data == 'request Too many') {
          showErrorDialog(context, '이메일을 너무 자주 전송하고 있어요. 조금 기다렸다 시도해보세요.');
        }
      }
    }
  }

  void startTimer() {
    setState(() {
      _remainingTime = 300; // 초 단위, 5분
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _timer?.cancel();
        const Text('시간이 초과되었습니다.');
      }
    });
  }

  void confirmVerification() async {
    // 인증 코드 확인 로직
    try {
      ApiService apiService = ApiService();
      Response response = await apiService.post(
        '/api/email/auth',
        data: {
          "verificationId": verificationId,
          "code": _verificationCodeController.text
        },
      );
      if (response.statusCode == 200) {
        _timer?.cancel();
        setState(() {
          _isVerified = true;
        });
      }
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

  void signUp() async {
    try {
      ApiService apiService = ApiService();
      Response response = await apiService.post(
        '/api/member/register',
        data: {
          "id": _idController.text,
          "password": _pwController.text,
          "nickname": _nicknameController.text,
          "email": _emailController.text,
        },
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
        await login();
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          builder: (BuildContext context) {
            return Theme(
              data: Theme.of(context).copyWith(
                dialogBackgroundColor: const Color(0xFFFFFFFF),
                dialogTheme: const DialogTheme(elevation: 0),
              ),
              child: const SignUpSuccess(),
            );
          },
        );
      } else {}
    } catch (e) {
      if (e is DioException) {
        print('에러났어요 이유 몰라요');
      }
    }
  }

  Future<void> login() async {
    try {
      _timer?.cancel();
      Provider.of<UserProvider>(context, listen: false).login(_idController.text, _pwController.text);
      Provider.of<UserProvider>(context, listen: false).fetchUserData();
    } catch (e) {
      print(e);
      // 로그인 과정 중 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 중 오류가 발생했습니다.'),
        ),
      );
    }
  }

  void idDuplicate() async {
    try {
      // API 서비스 객체 생성
      ApiService apiService = ApiService();

      // GET 요청
      Response response = await apiService.get(
        '/api/member/check?id=${_idController.text}',
      );

      // 상태 코드 200일 경우 처리
      if (response.statusCode == 200) {
        setState(() {
          _idSuccessMessage = '사용 가능한 아이디에요.';
          _idErrorMessage = '';
        });
      }
    } catch (e) {
      if (e is DioException) {
        setState(() {
          _idErrorMessage = '중복되는 아이디가 있어요.';
          _idSuccessMessage = '';
        });
      }
    }
  }

  void _validateNickname() {
    final nickname = _nicknameController.text;

    if (nickname.isEmpty) {
      _setNicknameError(null);
    } else if (nickname.length > 8) {
      _setNicknameError('닉네임은 8자 이내로 입력해야 합니다.');
    } else {
      _setNicknameError(null);
    }
  }

  void _setNicknameError(String? error) {
    setState(() {
      _nicknameError = error ?? '';
    });
  }

  void _handleButtonClick() {
    setState(() {
      _isButtonEnabled = false; // 버튼 비활성화
    });
    signUp();

    // 2초 후에 버튼을 다시 활성화
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isButtonEnabled = true; // 버튼 활성화
      });
    });
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '회원가입하기',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: ThemeColors.color1,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      '값을 모두 입력해야 회원가입이 가능해요.',
                      style: TextStyle(fontSize: 9, color: ThemeColors.color2),
                    ),
                    const SizedBox(height: 25),
                    TextForm(
                      title: '아이디',
                      controller: _idController,
                      errorText: _idError.isNotEmpty ? _idError : null,
                      suffix: IconButton(
                        onPressed: _idError == '' && _idController.text != ''
                            ? idDuplicate
                            : null,
                        icon: Text(
                          '중복검사하기',
                          style: TextStyle(color: ThemeColors.color1),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        if (_idSuccessMessage.isNotEmpty)
                          Text(
                            _idSuccessMessage,
                            style: const TextStyle(
                                color: Colors.green, fontSize: 12),
                          ),
                        if (_idErrorMessage.isNotEmpty)
                          Text(
                            _idErrorMessage,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextForm(
                      title: '이메일',
                      controller: _emailController,
                      errorText: _emailError.isNotEmpty ? _emailError : null,
                      suffix: IconButton(
                        onPressed:
                            _emailError == '' && _emailController.text != ''
                                ? emailDuplicate
                                : null,
                        icon: Text(
                          '인증하기',
                          style: TextStyle(color: ThemeColors.color1),
                        ),
                      ),
                    ),
                    if (_isCodeSent) ...[
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: TextForm(
                                  title: '이메일 인증 코드',
                                  controller: _verificationCodeController,
                                  suffix: IconButton(
                                    onPressed: confirmVerification,
                                    icon: Text(
                                      '확인',
                                      style:
                                          TextStyle(color: ThemeColors.color1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                flex: 1,
                                child: _isVerified
                                    ? const Text(
                                        '인증완료',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      )
                                    : Text(
                                        "${(_remainingTime / 60).floor().toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextForm(
                      title: '비밀번호',
                      controller: _pwController,
                      errorText: _pwError.isNotEmpty ? _pwError : null,
                    ),
                    const SizedBox(height: 20),
                    TextForm(
                      title: '비밀번호 확인',
                      controller: _pw2Controller,
                      errorText: _pw2Error.isNotEmpty ? _pw2Error : null,
                    ),
                    const SizedBox(height: 20),
                    TextForm(
                      title: '닉네임',
                      controller: _nicknameController,
                      errorText:
                          _nicknameError.isNotEmpty ? _nicknameError : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              _isVerified &&
                              _isButtonEnabled &&
                              _idSuccessMessage == '사용 가능한 아이디에요.' &&
                              _idError.isEmpty &&
                              _emailError.isEmpty &&
                              _pwError.isEmpty &&
                              _pw2Error.isEmpty &&
                              _nicknameError.isEmpty &&
                              _idController.text.isNotEmpty &&
                              _pwController.text.isNotEmpty &&
                              _pw2Controller.text.isNotEmpty &&
                              _emailController.text.isNotEmpty &&
                              _nicknameController.text.isNotEmpty) {
                            signUp();
                          } else {
                            showDialog<void>(
                              context: context,
                              barrierDismissible:
                                  false, // 다이얼로그 바깥을 터치해도 닫히지 않도록 설정
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('에러 발생'),
                                  content: const SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                            '아이디 중복 검사, 이메일 인증과 입력되지 않은 값을 확인해보세요.'),
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColors.color1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '가입하기',
                          style: TextStyle(
                            color: ThemeColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                dialogBackgroundColor: const Color(0xFFFFFFFF),
                                dialogTheme: const DialogTheme(elevation: 0),
                              ),
                              child: const LoginModal(),
                            );
                          },
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '계정이 있으신가요?',
                            style: TextStyle(
                              fontSize: 13,
                              color: ThemeColors.color1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
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
                                    child: const LoginModal(),
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
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
