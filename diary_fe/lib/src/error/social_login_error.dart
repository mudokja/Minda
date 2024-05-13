class SocialLoginError implements Exception {
  final String message;
  SocialLoginError(this.message);

  @override
  String toString() => message;
}
