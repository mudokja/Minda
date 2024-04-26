import 'package:diary_fe/src/models/user.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  ApiService apiService = ApiService();

  User user = User();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  // 토큰이 존재하는지 확인하고 상태 업데이트
  Future<void> checkLoginStatus() async {
    String? accessToken = await storage.read(key: "ACCESS_TOKEN");
    if (accessToken != null) {
      _isLoggedIn = true; // 토큰이 있으면 로그인된 것으로 간주
    } else {
      _isLoggedIn = false; // 토큰이 없으면 로그아웃된 것으로 간주
    }
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    Response response = await apiService.get('/api/member/my');
    if (response.statusCode == 200) {
      user = User.fromJson(response.data);
      notifyListeners();
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
