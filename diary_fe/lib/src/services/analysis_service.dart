import 'package:diary_fe/src/models/analysis_model.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:flutter/material.dart';

class AnalysisService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> fetchData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    String formStartDate = formatDate(startDate);
    String formEndDate = formatDate(endDate);
    Map<String, List<int>> emotions = {};

    try {
      var response = await _apiService.post('/api/diary/list/period', data: {
        "startDate": formStartDate,
        "endDate": formEndDate,
      });

      var jsonData = response.data;

      if (jsonData is List) {
        for (var item in jsonData) {
          if (item is Map<String, dynamic>) {
            AnalysisModel model = AnalysisModel.fromJson(item);
            String diaryDate = formatDate(model.diarySetDate);

            // 해당 날짜에 대한 감정 데이터가 없으면 초기화
            List<int> dailyEmotions =
                emotions.putIfAbsent(diaryDate, () => [0, 0, 0, 0, 0]);

            // 해당 날짜의 감정 데이터에 값을 추가
            dailyEmotions[0] += model.diaryHappiness;
            dailyEmotions[1] += model.diarySadness;
            dailyEmotions[2] += model.diaryFear;
            dailyEmotions[3] += model.diaryAnger;
            dailyEmotions[4] += model.diarySurprise;
          }
        }
        print(emotions);
        return {
          'emotions': emotions,
          'titles': jsonData.map((m) => m['diaryTitle']).toList(),
          'contents': jsonData.map((m) => m['diaryContent']).toList(),
          'images': jsonData.map((m) => m['imageList']).toList(),
          'hashtags': jsonData.map((m) => m['hashtagList']).toList(),
        };
      } else {
        return {
          'emotions': emotions,
          'titles': [],
          'contents': [],
          'images': [],
          'hashtags': [],
        };
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      return {
        'emotions': emotions,
        'titles': [],
        'contents': [],
        'images': [],
        'hashtags': [],
      };
    }
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
