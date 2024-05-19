import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev', useConstantCase: true)
abstract class Env {
  @EnviedField(varName: 'VAPID_KEY', obfuscate: true)
  static String vapidKey = _Env.vapidKey;
  @EnviedField(varName: 'KAKAO_APIKEY', obfuscate: true)
  static String kakaoApiKey = _Env.kakaoApiKey;
  @EnviedField(varName: 'KAKAO_JSKEY', obfuscate: true)
  static String kakaoJSKey = _Env.kakaoJSKey;
  @EnviedField(varName: 'BASE_URL')
  static const String baseUrl = _Env.baseUrl;
  @EnviedField(varName: 'API_URL')
  static const String apiUrl = _Env.apiUrl;
  @EnviedField(varName: 'AI_URL')
  static const String aiUrl = _Env.aiUrl;
  @EnviedField(varName: 'STT_KEY', obfuscate: true)
  static String sttKey= _Env.sttKey;
}
