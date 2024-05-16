// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
      index: (json['memberIndex'] as num?)?.toInt() ?? 0,
      id: json['memberId'] as String? ?? '',
      email: json['memberEmail'] as String? ?? '',
      nickname: json['memberNickname'] as String? ?? '',
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'memberIndex': instance.index,
      'memberId': instance.id,
      'memberEmail': instance.email,
      'memberNickname': instance.nickname,
    };
