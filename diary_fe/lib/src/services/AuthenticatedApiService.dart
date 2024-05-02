// import 'package:dio/dio.dart';
// import 'package:diary_fe/src/services/auth_service.dart';
// import 'package:diary_fe/src/services/api_services.dart';

// class AuthenticatedApiService extends ApiService {
//   final AuthService _authService;

//   AuthenticatedApiService(this._authService) : super() {
//     // Dio 인터셉터 추가하기 전에 상위 클래스의 Dio 인스턴스를 활용합니다.
//     // super()를 호출하여 ApiService의 기본 설정을 상속받습니다.
    
//     // 추가적인 인터셉터를 설정하여 인증이 필요한 요청을 관리합니다.
//     dio.interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) async {
//         var token = await _authService.getToken();  // AuthService에서 토큰을 가져옵니다.
//         if (token != null) {
//           options.headers["Authorization"] = "Bearer $token";  // 헤더에 토큰 추가
//         } else if (options.headers.containsKey('Requires-Auth')) {
//           // 'Requires-Auth' 헤더가 있는 요청에 대해서만 토큰을 요구하는 경우
//           throw DioException(
//             requestOptions: options,
//             message: "No authentication token available",
//             type: DioExceptionType.badResponse,
//           );
//         }
//         return handler.next(options);
//       },
//     ));
//   }
// }
