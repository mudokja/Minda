// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$UserFromJson(Map<String, dynamic> json) => AppUser(
      index: json['memberIndex'] as int? ?? 0,
      id: json['memberId'] as String? ?? '',
      nickname: json['memberNickname'] as String? ?? '',
      email: json['memberEmail'] as String? ?? '',
    );

Map<String, dynamic> _$UserToJson(AppUser instance) => <String, dynamic>{
      'memberIndex': instance.index,
      'memberId': instance.id,
      'memberNickname': instance.nickname,
      'memberEmail': instance.email,
    };
