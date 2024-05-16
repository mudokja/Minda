import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class AppUser {
  @JsonKey(name: 'memberIndex')
  final int? index;
  @JsonKey(name: 'memberId')
  final String? id;
  @JsonKey(name: 'memberEmail')
  final String? email;
  @JsonKey(name: 'memberNickname')
  final String? nickname;

  AppUser({
    this.index = 0,
    this.id = '',
    this.email = '',
    this.nickname = '',
  });

  // Json 직렬화 및 역직렬화를 위한 메서드
  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}
