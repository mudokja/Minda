import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:diary_fe/env/env.dart';
import 'package:diary_fe/src/error/social_login_error.dart';
import 'package:diary_fe/src/models/user.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:diary_fe/src/services/notification_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'delete_storage.dart';

class UserProvider with ChangeNotifier {
  ApiService apiService = ApiService();
  final Future<SharedPreferences> _sharedPreference =
      SharedPreferences.getInstance();
  AppUser user = AppUser();

  DeleteStorage deleteStorage = DeleteStorage();
  late User? kakaoUser;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;
  final bool _isLoading = true; // 로딩 상태 추가

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  UserProvider() {
    checkInitialLogin();
  }
  Future<void> _tokenRegister() async {
    await NotificationService().tokenRegister();
  }

  Future<void> login(String id, String pw) async {
    Response response = await apiService
        .post('/api/auth/login', data: {"id": id, "password": pw});
    Map<String, dynamic> responseMap = response.data;
    _fetchTokenInfo(responseMap);
    await _tokenRegister();
  }

  Future<void> logout() async {
    String? refreshToken = await storage.read(key: "REFRESH_TOKEN");
    await apiService.delete('/api/auth/logout?refreshToken=$refreshToken');
    await NotificationService().tokenDelete();
    deleteStorage.deleteAll();
  }

  Future<void> leave() async {
    await logout();
    await unLink();

    await apiService.delete("/api/member");
  }

  Future<void> _webKakaoLogin() async {
    bool talkInstalled = await isKakaoTalkInstalled();
    if (talkInstalled) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        try {
          await UserApi.instance.loginWithKakaoAccount();
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
      } catch (error) {
        debugPrint('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  Future<void> kakaoLogin() async {
    bool talkInstalled = await isKakaoTalkInstalled();

    debugPrint("호출 카카오");
    try {
      if (kIsWeb) {
        //웹 방식 로그인은 문제가 발생하지 않으면 별도로 구현하지 않을예정
        _webKakaoLogin();
      } else {
        if (Platform.isAndroid || Platform.isIOS) {
          if (talkInstalled) {
            try {
              await UserApi.instance.loginWithKakaoTalk();
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
              } catch (error) {
                print('카카오계정으로 로그인 실패 $error');
              }
            }
          } else {
            try {
              await UserApi.instance.loginWithKakaoAccount();
            } catch (error) {
              debugPrint('카카오계정으로 로그인 실패 $error');
            }
          }
        }
      }
      Map<String, dynamic> response = await _requestOauth2KakaoLogin();
      await _fetchTokenInfo(response);
      await _tokenRegister();
    } catch (error) {
      debugPrint('카카오 로그인 실패 $error');
      rethrow;
    }
  }

  Future<void> retryKakaoLogin(String? email) async {
    kakaoUser = await UserApi.instance.me();
    if (email == null && kakaoUser?.kakaoAccount?.email == null) {
      throw SocialLoginError("Email Required");
    }

    Map requestData = {
      "platform": "KAKAO",
      "id": kakaoUser?.id,
      "nickname": kakaoUser?.kakaoAccount?.profile?.nickname,
      "email": email ?? kakaoUser?.kakaoAccount?.email
    };
    Response? response;
    try {
      response =
          await apiService.post("/api/auth/oauth2/login", data: requestData);
      _fetchTokenInfo(response.data);
      await _tokenRegister();
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          switch (e.response?.data) {
            case "email is empty":
              throw SocialLoginError("Email Required");
            default:
              throw SocialLoginError("Register Failed");
          }
        }
      }
    }
  }

  Future<Map<String, dynamic>> _requestOauth2KakaoLogin() async {
    kakaoUser = await UserApi.instance.me();
    Map requestData = {
      "platform": "KAKAO",
      "id": kakaoUser?.id,
      "nickname": kakaoUser?.kakaoAccount?.profile?.nickname,
      "email": kakaoUser?.kakaoAccount?.email
    };
    Response? response;
    try {
      response =
          await apiService.post("/api/auth/oauth2/login", data: requestData);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          switch (e.response?.data) {
            case "email is empty":
              throw SocialLoginError("Email Required");
            default:
              throw SocialLoginError("Register Failed");
          }
        }
      }
    }

    return response?.data;
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
      await _tokenRegister();
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
        // throw Exception('Failed to load user data');
      }
    } catch (e) {
      // throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<void> unLink() async {
    await UserApi.instance.unlink();
  }
}
