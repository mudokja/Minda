// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      index: json['index'] as int? ?? 0,
      id: json['memberId'] as String? ?? '',
      nickname: json['memberNickName'] as String? ?? '',
      email: json['membberEmail'] as String? ?? '',
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'index': instance.index,
      'id': instance.id,
      'nickname': instance.nickname,
      'email': instance.email,
    };
