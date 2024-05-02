import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  Dio dio = Dio();

  String baseUrl = 'https://k10b205.p.ssafy.io';
  final storage = const FlutterSecureStorage();
  ApiService() {
    // bool refresh = true;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? accessToken = await storage.read(key: 'ACCESS_TOKEN');
          options.headers['Authorization'] = 'Bearer $accessToken';
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // 에러 발생시 처리하는 부분
        },
      ),
    );
  }
  Future<Response> get(String url) async {
    Response response;
    try {
      response = await dio.get(baseUrl + url);
    } on Error catch (e) {
      // 요청 실패 시 처리
      throw Exception('Failed to load data: $e');
    }
    return response;
  }

  Future<Response> post(String url, {dynamic data}) async {
    Response response;

    try {
      response = await dio.post(baseUrl + url, data: data);
    } on Error catch (e) {
      // 요청 실패 시 처리
      throw Exception('Failed to load data: $e');
    }
    return response;
  }

  Future<Response> put(String url, {dynamic data}) async {
    Response response;
    try {
      response = await dio.put(baseUrl + url, data: data);
    } on Error catch (e) {
      // 요청 실패 시 처리
      throw Exception('Failed to load data: $e');
    }
    return response;
  }

  Future<Response> delete(String url) async {
    Response response;
    try {
      response = await dio.delete(baseUrl + url);
    } on Error catch (e) {
      // 요청 실패 시 처리
      throw Exception('Failed to load data: $e');
    }
    return response;
  }
}
