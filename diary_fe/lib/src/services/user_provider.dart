import 'dart:convert';
import 'dart:io' show Platform;
import 'package:diary_fe/src/models/user.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UserProvider with ChangeNotifier {
  ApiService apiService = ApiService();
  final Future<SharedPreferences> _sharedPreference = SharedPreferences.getInstance();
  AppUser user = AppUser();
  late User? kakaoUser;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;
  final bool _isLoading = true; // 로딩 상태 추가

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  UserProvider() {
    checkInitialLogin();
  }
  Future<void> login(String id, String pw) async {

    ApiService apiService = ApiService();
    Response response = await apiService.post('/api/auth/login',
        data: {"id": id, "password": pw});
    Map<String, dynamic> responseMap = response.data;
    await storage.write(key: "ACCESS_TOKEN", value: responseMap["accessToken"]);
    await storage.write(
      key: "REFRESH_TOKEN",
      value: responseMap["refreshToken"],
    );

  }
  Future<void> kakaoLogin() async {
    debugPrint("호출 카카오");
    try{

    }catch (error){

    }
    if(kIsWeb || Platform.isAndroid || Platform.isIOS ){
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
          try {
            kakaoUser =await UserApi.instance.me();
            debugPrint('사용자 정보 요청 성공'
                '\n회원번호: ${kakaoUser?.id}'
                '\n닉네임: ${kakaoUser?.kakaoAccount?.profile?.nickname}'
                '\n이메일: ${kakaoUser?.kakaoAccount?.email}');
          } catch (error) {
            print('사용자 정보 요청 실패 $error');
          }
        } catch (error) {
          print('카카오톡으로 로그인 실패 $error');

          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
          if (error is PlatformException && error.code == 'CANCELED') {
            return;
          }
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            await UserApi.instance.loginWithKakaoAccount();
            kakaoUser =await UserApi.instance.me();
            print('사용자 정보 요청 성공'
                '\n회원번호: ${kakaoUser?.id}'
                '\n닉네임: ${kakaoUser?.kakaoAccount?.profile?.nickname}'
                '\n이메일: ${kakaoUser?.kakaoAccount?.email}');
            print('카카오계정으로 로그인 성공');
          } catch (error) {
            print('카카오계정으로 로그인 실패 $error');
          }
        }
    }else{
        try {
          await UserApi.instance.loginWithKakaoAccount();
          kakaoUser =await UserApi.instance.me();
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
    }
    }
  }

  Future<void> checkInitialLogin() async {
    String? accessToken = await storage.read(key: "ACCESS_TOKEN");
    if (accessToken != null) {
      _isLoggedIn = true;
      await fetchUserData();
    } else {
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    try {
      Response response = await apiService.get('/api/member/my');
      if (response.statusCode == 200) {
        user = AppUser.fromJson(response.data);
        // 사용자 데이터를 저장
        await storage.write(
            key: "USER_DATA", value: json.encode(user.toJson()));
        notifyListeners(); // 데이터 변경 시 리스너에게 알림
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }
}
