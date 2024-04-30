import 'dart:convert';

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
  final bool _isLoading = true; // 로딩 상태 추가

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  UserProvider() {
    checkInitialLogin();
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
        user = User.fromJson(response.data);
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
