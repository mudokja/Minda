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
    Map<String, List<double>> emotions = {};

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

            List<double> dailyEmotions =
                emotions.putIfAbsent(diaryDate, () => List.filled(5, 0.0));

            dailyEmotions[0] += model.diaryHappiness;
            dailyEmotions[1] += model.diarySadness;
            dailyEmotions[2] += model.diaryFear;
            dailyEmotions[3] += model.diaryAnger;
            dailyEmotions[4] += model.diarySurprise;
          }
        }

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
