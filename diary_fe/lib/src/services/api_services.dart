import 'package:diary_fe/src/services/delete_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  bool refresh = true;
  Dio dio = Dio();

  String baseUrl = 'https://k10b205.p.ssafy.io';
// String baseUrl = 'http://192.168.31.35:8000';
  //String baseUrl = 'http://localhost:8082';
  final storage = const FlutterSecureStorage();
  ApiService() {
    // bool refresh = true;
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
        String? accessToken = await storage.read(key: 'ACCESS_TOKEN');
        options.headers['Authorization'] = 'Bearer $accessToken';
        return handler.next(options);
      }, onError: (DioException error, handler) async {
        if (error.response?.statusCode == 404 ||
            error.response?.statusCode == 400 ||
            error.response?.statusCode == 409) {
          handler.next(error);
        } else if (error.response?.statusCode == 401 && refresh) {
          String? refreshToken = await storage.read(key: 'REFRESH_TOKEN');
          if (refreshToken != null) {
            try {
              refresh = false;

              Dio dio = Dio();
              Response refreshResponse = await dio.post(
                "$baseUrl/api/auth/refresh",
                data: {"refreshToken": refreshToken},
              );
              String newAccessToken = refreshResponse.data["accessToken"];
              await storage.write(key: 'ACCESS_TOKEN', value: newAccessToken);
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final opts = Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              );
              refresh = true;
              return handler.resolve(await dio.request(
                baseUrl + error.requestOptions.path,
                options: opts,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              ));
            } catch (refreshError) {
              if(refreshError is DioException){
                handler.next(refreshError);
              }
              return;
            }
          } else {
            refresh=false;
            // throw Exception('Refresh token not found');
          }
        } else if (error.response?.statusCode == 401 && !refresh) {
          DeleteStorage deleteStorage = DeleteStorage();
          deleteStorage.deleteAll();
        }
      }),
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
