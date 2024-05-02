import 'dart:convert';
import 'dart:developer';
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
  final Future<SharedPreferences> _sharedPreference =
      SharedPreferences.getInstance();
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
    Response response = await apiService
        .post('/api/auth/login', data: {"id": id, "password": pw});
    Map<String, dynamic> responseMap = response.data;
    _fetchTokenInfo(responseMap);
  }

  Future<void> kakaoLogin() async {
    bool talkInstalled = await isKakaoTalkInstalled();

    var key = await KakaoSdk.origin;
    log(key);
    debugPrint("호출 카카오");
    try {
      if (kIsWeb) {
        //웹 방식 로그인은 문제가 발생하지 않으면 별도로 구현하지 않을예정
        if (talkInstalled) {
          try {
            await UserApi.instance.loginWithKakaoTalk();
            Map<String, dynamic> response = await _requestOauth2KakaoLogin();
            await _fetchTokenInfo(response);
          } catch (error) {
            print('카카오톡으로 로그인 실패 $error');

            // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
            // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
            if (error is PlatformException && error.code == 'CANCELED') {
              return;
            }
            try {
              await UserApi.instance.loginWithKakaoAccount();
              Map<String, dynamic> response = await _requestOauth2KakaoLogin();
              await _fetchTokenInfo(response);
            } catch (error) {
              print('카카오계정으로 로그인 실패 $error');
            }
          }
        } else {
          try {
            await UserApi.instance.loginWithKakaoAccount();
            Map<String, dynamic> response = await _requestOauth2KakaoLogin();
            await _fetchTokenInfo(response);
          } catch (error) {
            debugPrint('카카오계정으로 로그인 실패 $error');
          }
        }
      } else {
        if (Platform.isAndroid || Platform.isIOS) {
          if (talkInstalled) {
            try {
              await UserApi.instance.loginWithKakaoTalk();
              Map<String, dynamic> response = await _requestOauth2KakaoLogin();
              await _fetchTokenInfo(response);
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
                Map<String, dynamic> response =
                    await _requestOauth2KakaoLogin();
                await _fetchTokenInfo(response);
              } catch (error) {
                print('카카오계정으로 로그인 실패 $error');
              }
            }
          } else {
            try {
              await UserApi.instance.loginWithKakaoAccount();
              Map<String, dynamic> response = await _requestOauth2KakaoLogin();
              await _fetchTokenInfo(response);
            } catch (error) {
              debugPrint('카카오계정으로 로그인 실패 $error');
            }
          }
        }
      }
    } catch (error) {
      print('카카오계정으로 로그인 실패 $error');
    }
  }

  Future<Map<String, dynamic>> _requestOauth2KakaoLogin() async {
    kakaoUser = await UserApi.instance.me();
    Response response = await apiService.post("/api/auth/oauth2/login", data: {
      "platform": "KAKAO",
      "id": kakaoUser?.id,
      "nickname": kakaoUser?.kakaoAccount?.profile?.nickname,
      "email": kakaoUser?.kakaoAccount?.email
    });
    return response.data;
  }

  Future<void> _fetchTokenInfo(Map<String, dynamic> responseMap) async {
    await storage.write(key: "ACCESS_TOKEN", value: responseMap["accessToken"]);
    await storage.write(
      key: "REFRESH_TOKEN",
      value: responseMap["refreshToken"],
    );
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
