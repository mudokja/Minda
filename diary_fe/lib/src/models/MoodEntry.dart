import 'package:flutter/material.dart';

class MoodEntry {
  final DateTime date;
  final String? diary_happiness; // 기쁨
  final String? diary_sadness; // 슬픔
  final String? diary_fear; // 불안
  final String? diary_anger; // 분노
  final String? diary_disgust; // 상처
  final String? diary_surprise; // 놀람

  MoodEntry({
    required this.date,
    this.diary_happiness,
    this.diary_sadness,
    this.diary_fear,
    this.diary_anger,
    this.diary_disgust,
    this.diary_surprise,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']),
      diary_happiness: json['diary_happiness'] as String?,
      diary_sadness: json['diary_sadness'] as String?,
      diary_fear: json['diary_fear'] as String?,
      diary_anger: json['diary_anger'] as String?,
      diary_disgust: json['diary_disgust'] as String?,
      diary_surprise: json['diary_surprise'] as String?,
    );
  }
}

Color getColorFromMood(String? mood) {
  switch (mood) {
    case '기쁨':
      return const Color(0xFFF5AC25); // 노랑
    case '슬픔':
      return const Color(0xFFBC7FCD); // 연보라
    case '불안':
      return const Color(0xFFB3B4B4); // 회색
    case '분노':
      return const Color(0xFFDF1E1E); // 빨강
    case '상처':
      return const Color(0xFF86469C); // 진보라
    case '놀람':
      return const Color(0xFFFC819E); // 분홍
    default:
      return Colors.transparent; // 기본 색상
  }
}
