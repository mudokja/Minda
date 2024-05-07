import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:diary_fe/src/models/MoodEntry.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';


// class DiaryApiService {
//   final Dio _dio;

//   DiaryApiService(this._dio);

//   Future<List<MoodEntry>> fetchDiaryEntries() async {
//     try {
//       Response response = await _dio.get('https://k10b205.p.ssafy.io');
//       print(response.data);  // 응답 로그 출력
//       return (response.data as List)
//           .map((data) => MoodEntry.fromJson(data))
//           .toList();
//     } catch (e) {
//       print(e);  // 에러 상세 정보 출력
//       throw Exception('Failed to load diary entries: $e');
//     }
//   }
// }

// class DiaryApiService {
//   Dio _dio = Dio();

//   DiaryApiService() {
//     _dio = Dio(BaseOptions(baseUrl: "https://k10b205.p.ssafy.io/api"));
//   }

//   Future<List<DiaryEntry>> fetchDiaryEntries() async {
//     try {
//       Response response = await _dio.get('/diary/list');
//       return (response.data as List)
//           .map((data) => DiaryEntry.fromJson(data))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load diary entries: $e');
//     }
//   }
// }

// import 'package:dio/dio.dart';

// class DiaryApiService {
//   Dio _dio;

//   DiaryApiService() {
//     _dio = Dio(BaseOptions(
//       baseUrl: "https://k10b205.p.ssafy.io/api",  // 기본 URL 설정
//       connectTimeout: 5000,  // 연결 타임아웃 5000ms
//       receiveTimeout: 3000,  // 응답 타임아웃 3000ms
//     ));
//   }

//   Future<List<MoodEntry>> fetchDiaryEntries() async {
//     try {
//       Response response = await _dio.get('/diary/list');  // 상대 경로 사용
//       return (response.data as List)
//           .map((data) => MoodEntry.fromJson(data))
//           .toList();
//     } catch (e) {
//       print(e);
//       throw Exception('Failed to load diary entries: $e');
//     }
//   }
// }

// import 'package:dio/dio.dart';
// import 'package:diary_fe/src/models/DiaryEntry.dart';  // DiaryEntry 모델 import

// class DiaryApiService {
//   late Dio _dio;

//   DiaryApiService() {
//     _dio = Dio(BaseOptions(
//       baseUrl: "https://k10b205.p.ssafy.io/api",  // 기본 URL 설정
//       connectTimeout: const Duration(milliseconds: 5000),  // 연결 타임아웃 5000ms
//       receiveTimeout: const Duration(milliseconds: 3000),  // 응답 타임아웃 3000ms
//     ));
//   }

//   Future<List<DiaryEntry>> fetchDiaryEntries() async {
//     try {
//       Response response = await _dio.get('/diary/list');  // 상대 경로 사용
//       return (response.data as List)
//           .map((data) => DiaryEntry.fromJson(data as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       print(e);
//       throw Exception('Failed to load diary entries: $e');
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DiaryApiService {
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  // API 요청에 자동으로 토큰을 추가하기 위한 인터셉터 설정
  // flutter_secure_storage를 사용하여 저장된 토큰을 가져옴

  DiaryApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: "https://k10b205.p.ssafy.io/api",
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
    ));

    // 요청과 응답을 로깅하는 인터셉터 추가
    _dio.interceptors
        .add(LogInterceptor(requestBody: true, responseBody: true));

    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      String? token = await _storage.read(key: "ACCESS_TOKEN");
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        print("No token available.");
      }
      return handler.next(options);
    }, onResponse: (response, handler) {
      // 응답 로그 출력
      print(response.data);
      return handler.next(response);
    }, onError: (DioError e, handler) {
      print(e.message);
      return handler.next(e);
    }));
  }

  Future<List<DiaryEntry>> fetchDiaryEntries() async {
    try {
      Response response = await _dio.get('/diary/list');
      return (response.data as List)
          .map((data) => DiaryEntry.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load diary entries: $e');
    }
  }

// 선택된 날짜의 일기를 가져오는 함수
//   Future<DiaryEntry> fetchDiaryEntryByDate(DateTime date) async {
//     try {
//       String dateString =
//           "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//       Response response =
//           await _dio.get('/diary/list/period', queryParameters: {'date': dateString});
//       if (response.data != null) {
//         return DiaryEntry.fromJson(response.data);
//       } else {
//         throw Exception('No diary entry found for this date.');
//       }
//     } catch (e) {
//       throw Exception('Failed to load diary entry: $e');
//     }
//   }
// Future<List<DiaryEntry>> fetchDiaryEntriesByDate(DateTime date) async {
//   try {
//     String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//     Response response = await _dio.post('/diary/list/period', queryParameters: {
//       'startDate': dateString,
//       'endDate': dateString
//     });
//     if (response.data != null && response.data.isNotEmpty) {
//       List<DiaryEntry> entries = (response.data as List)
//           .map((data) => DiaryEntry.fromJson(data as Map<String, dynamic>))
//           .toList();
//       return entries;
//     } else {
//       throw Exception('No diary entries found for this date.');
//     }
//   } catch (e) {
//     throw Exception('Failed to load diary entries: $e');
//   }
// }

// Future<DiaryEntry> fetchDiaryEntryByDate(DateTime date) async {
//   try {
//     String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//     var data = {
//       "startDate": dateString,
//       "endDate": dateString
//     };

//     // JSON 데이터를 서버에 전송하기 위해 헤더 설정
//     _dio.options.headers['content-type'] = 'application/json';
//     _dio.options.headers['Authorization'] = 'Bearer ${await _storage.read(key: "ACCESS_TOKEN")}';

//     Response response = await _dio.post(
//       '/diary/list/period',
//       data: data
//     );

//     if (response.data != null && response.statusCode == 200) {
//       return DiaryEntry.fromJson(response.data);
//     } else {
//       throw Exception('No diary entry found for this date.');
//     }
//   } catch (e) {
//     throw Exception('Failed to load diary entry: $e');
//   }
// }

Future<List<DiaryEntry>> fetchDiaryEntriesByDate(DateTime date) async {
  String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  var data = jsonEncode({
    "startDate": dateString,
    "endDate": dateString
  });

  try {
    Response response = await _dio.post(
      '/diary/list/period',
      data: data
    );
    if (response.data != null && response.statusCode == 200) {
      List<DiaryEntry> entries = List<DiaryEntry>.from(response.data.map((model) => DiaryEntry.fromJson(model)));
      return entries;
    } else {
      throw Exception('No diary entries found for this date.');
    }
  } catch (e) {
    throw Exception('Failed to load diary entries: $e');
  }
}


}
