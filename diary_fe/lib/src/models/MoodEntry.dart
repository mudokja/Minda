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
}


Color getColorFromMood(String? mood) {
  switch (mood) {
    case '기쁨':
      return const Color(0xFFF9F871); // 노랑
    case '슬픔':
      return const Color(0xFF845EC2); // 보라
    case '불안':
      return const Color(0xFFD65DB1); // 자주
    case '분노':
      return const Color(0xFFFF9671); // 주황
    case '상처':
      return const Color(0xFFFFC75F); // 진노랑
    case '놀람':
      return const Color(0xFFFF6F91); // 분홍
    default:
      return Colors.transparent; // 기본 색상
  }
}

